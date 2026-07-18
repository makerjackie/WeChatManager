import AppKit
import Foundation
import Observation

@MainActor
@Observable
final class AppModel {
    var selectedPage: NavigationPage? = .overview
    var installation: WeChatInstallation?
    var runningInstanceCount = 0
    var clones: [WeChatClone] = []
    var clonePlans: [ClonePlan] = []
    var isRefreshing = false
    var isCreatingClone = false
    var isRunningCloneOperation = false
    var cloneOperationProgress = 0.0
    var cloneOperationDescription = ""
    var isPlanCloudAvailable = false
    var compatibility: EnhancementCompatibility = .checking
    var selectedEnhancements: Set<EnhancementOption> = [.multiInstance]
    var hasEnhancementBackup = false
    var message: UserMessage?
    var showsInstallConfirmation = false
    var showsRestoreConfirmation = false
    var showsPermissionGuide = false
    var showsSavePlanSheet = false

    let updateController = UpdateController()

    @ObservationIgnored
    private let launchService = WeChatLaunchService()
    @ObservationIgnored
    private let cloneService = WeChatCloneService()
    @ObservationIgnored
    private let enhancementService = EnhancementService()
    @ObservationIgnored
    private let permissionGuideStore: PermissionGuideStore
    @ObservationIgnored
    private let clonePlanStore: ClonePlanStore

    init(
        permissionGuideStore: PermissionGuideStore = PermissionGuideStore(),
        clonePlanStore: ClonePlanStore = ClonePlanStore()
    ) {
        self.permissionGuideStore = permissionGuideStore
        self.clonePlanStore = clonePlanStore
        clonePlanStore.onExternalChange = { [weak self] in
            self?.reloadClonePlans()
        }
    }

    var outdatedClones: [WeChatClone] {
        guard let installation else { return [] }
        return clones.filter {
            !$0.isInstalledInApplicationsFolder || $0.sourceBuild != installation.build
        }
    }

    var appVersionDescription: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "未知"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "未知"
        return "版本 \(version)（\(build)）"
    }

    func start() async {
        reloadClonePlans()
        guard !permissionGuideStore.shouldPresentGuide else {
            showsPermissionGuide = true
            return
        }
        await refreshContent()
    }

    func refresh() {
        guard ensurePermissionGuideCompleted() else { return }
        Task { await refreshContent() }
    }

    func refreshClonePlans() {
        reloadClonePlans()
        message = UserMessage(
            title: "方案已刷新",
            detail: isPlanCloudAvailable ? "已读取最新方案。" : "已读取本机方案。"
        )
    }

    func launchOfficial() {
        guard ensurePermissionGuideCompleted() else { return }
        Task {
            do {
                try await launchService.launchOfficial()
                try? await Task.sleep(for: .seconds(1))
                runningInstanceCount = launchService.runningInstanceCount()
            } catch {
                present(error: error, title: "无法启动微信")
            }
        }
    }

    func launchAdditionalInstance() {
        guard ensurePermissionGuideCompleted() else { return }
        guard !isCreatingClone else { return }
        Task {
            do {
                let currentClones = await cloneService.clones()
                if let availableClone = currentClones.first(where: {
                    !launchService.isRunning(bundleIdentifier: $0.bundleIdentifier)
                }) {
                    let preparedClone = try await preparedCloneForLaunch(availableClone)
                    try await launchService.launch(applicationURL: preparedClone.applicationURL)
                } else {
                    guard let installation else {
                        throw AppError(message: "请先安装微信。")
                    }
                    isCreatingClone = true
                    defer { isCreatingClone = false }
                    let newClone = try await cloneService.createNext(from: installation)
                    try await launchService.launch(applicationURL: newClone.applicationURL)
                }
                try? await Task.sleep(for: .seconds(2))
                await refreshContent()
            } catch {
                present(error: error, title: "无法打开微信分身")
            }
        }
    }

    func terminateAllInstances() {
        launchService.terminateAll()
        Task {
            try? await Task.sleep(for: .seconds(1))
            runningInstanceCount = launchService.runningInstanceCount()
        }
    }

    func requestEnhancementInstall() {
        guard ensurePermissionGuideCompleted() else { return }
        showsInstallConfirmation = true
    }

    func toggleEnhancement(_ option: EnhancementOption) {
        if selectedEnhancements.contains(option) {
            selectedEnhancements.remove(option)
        } else {
            selectedEnhancements.insert(option)
        }
    }

    func installEnhancements() {
        Task { await performEnhancementInstall() }
    }

    func requestRestore() {
        guard ensurePermissionGuideCompleted() else { return }
        showsRestoreConfirmation = true
    }

    func restoreOfficialWeChat() {
        Task { await performRestore() }
    }

    func createClone() {
        guard ensurePermissionGuideCompleted() else { return }
        guard !isCreatingClone else { return }
        Task {
            guard let installation else {
                message = UserMessage(title: "没有找到微信", detail: "请先安装微信。")
                return
            }
            isCreatingClone = true
            defer { isCreatingClone = false }
            do {
                let clone = try await cloneService.createNext(from: installation)
                let detail = installation.isOfficiallySigned
                    ? "\(clone.displayName) 已创建。"
                    : "\(clone.displayName) 已按当前微信创建。"
                message = UserMessage(title: "分身已创建", detail: detail)
                await refreshContent()
            } catch {
                present(error: error, title: "创建分身失败")
            }
        }
    }

    func saveClonePlan(name: String, selectedCloneIDs: Set<String>) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            message = UserMessage(title: "方案名称不能为空", detail: "请输入一个容易辨认的方案名称。")
            return false
        }
        let normalizedName = String(trimmedName.prefix(40))

        let selectedClones = clones
            .filter { selectedCloneIDs.contains($0.id) }
            .sorted { $0.index < $1.index }
        guard !selectedClones.isEmpty else {
            message = UserMessage(title: "尚未选择分身", detail: "请至少选择一个微信分身。")
            return false
        }
        guard selectedClones.count <= 20 else {
            message = UserMessage(title: "分身数量过多", detail: "一个方案最多保存 20 个微信分身。")
            return false
        }
        guard let installation else {
            message = UserMessage(title: "没有找到微信", detail: "请先安装微信。")
            return false
        }

        let existingPlan = clonePlans.first {
            $0.name.caseInsensitiveCompare(normalizedName) == .orderedSame
        }
        let now = Date.now
        let plan = ClonePlan(
            id: existingPlan?.id ?? UUID(),
            name: normalizedName,
            items: selectedClones.map {
                ClonePlanItem(index: $0.index, displayName: $0.displayName)
            },
            sourceVersion: installation.version,
            sourceBuild: installation.build,
            createdAt: existingPlan?.createdAt ?? now,
            modifiedAt: now
        )
        clonePlans.removeAll { $0.id == plan.id }
        clonePlans.insert(plan, at: 0)
        isPlanCloudAvailable = clonePlanStore.save(clonePlans)
        message = UserMessage(
            title: existingPlan == nil ? "方案已保存" : "方案已更新",
            detail: isPlanCloudAvailable
                ? "“\(normalizedName)”已同步到 iCloud。"
                : "“\(normalizedName)”已保存在本机。"
        )
        return true
    }

    func deleteClonePlan(_ plan: ClonePlan) {
        clonePlans.removeAll { $0.id == plan.id }
        isPlanCloudAvailable = clonePlanStore.save(clonePlans)
        message = UserMessage(
            title: "方案已删除",
            detail: "已安装的分身不受影响。"
        )
    }

    func applyClonePlan(_ plan: ClonePlan) {
        guard ensurePermissionGuideCompleted(), !isRunningCloneOperation else { return }
        Task { await performApplyClonePlan(plan) }
    }

    func updateAllClones() {
        guard ensurePermissionGuideCompleted(), !isRunningCloneOperation else { return }
        Task { await performUpdateAllClones() }
    }

    func launch(_ clone: WeChatClone) {
        Task {
            do {
                let preparedClone = try await preparedCloneForLaunch(clone)
                try await launchService.launch(applicationURL: preparedClone.applicationURL)
                try? await Task.sleep(for: .seconds(1))
                runningInstanceCount = launchService.runningInstanceCount()
            } catch {
                present(error: error, title: "无法启动分身")
            }
        }
    }

    func reveal(_ clone: WeChatClone) {
        NSWorkspace.shared.activateFileViewerSelecting([clone.applicationURL])
    }

    func update(_ clone: WeChatClone) {
        guard !isCreatingClone else { return }
        Task {
            guard let installation else { return }
            guard !launchService.isRunning(bundleIdentifier: clone.bundleIdentifier) else {
                message = UserMessage(title: "请先退出分身", detail: "更新 \(clone.displayName) 前请先退出它。")
                return
            }
            isCreatingClone = true
            defer { isCreatingClone = false }
            do {
                _ = try await cloneService.update(clone, from: installation)
                message = UserMessage(title: "分身已更新", detail: "已更新到微信 \(installation.version)，登录数据保留。")
                await refreshContent()
            } catch {
                present(error: error, title: "更新分身失败")
            }
        }
    }

    func moveToTrash(_ clone: WeChatClone) {
        Task {
            guard !launchService.isRunning(bundleIdentifier: clone.bundleIdentifier) else {
                message = UserMessage(title: "请先退出分身", detail: "移入废纸篓前请先退出 \(clone.displayName)。")
                return
            }
            do {
                _ = try await cloneService.moveToTrash(clone)
                message = UserMessage(title: "分身已移入废纸篓", detail: "聊天数据已保留。")
                await refreshContent()
            } catch {
                present(error: error, title: "无法移除分身")
            }
        }
    }

    func isRunning(_ clone: WeChatClone) -> Bool {
        launchService.isRunning(bundleIdentifier: clone.bundleIdentifier)
    }

    func openRepository() {
        NSWorkspace.shared.open(AppConstants.repositoryURL)
    }

    func openUpstreamRepository() {
        NSWorkspace.shared.open(AppConstants.upstreamRepositoryURL)
    }

    func showPermissionGuide() {
        showsPermissionGuide = true
    }

    func deferPermissionGuide() {
        showsPermissionGuide = false
    }

    func completePermissionGuide() {
        permissionGuideStore.markCompleted()
        showsPermissionGuide = false
        Task { await refreshContent() }
    }

    func requestWeChatApplicationAccess() async -> PermissionGuideResult {
        guard launchService.applicationURL() != nil else {
            return .unavailable("这台 Mac 尚未安装微信；安装后刷新即可继续。")
        }
        guard let checkedInstallation = await launchService.installation() else {
            return .needsAction("系统尚未允许读取微信应用。请在系统提示中选择“允许”，然后重试。")
        }

        installation = checkedInstallation
        let detail = checkedInstallation.isOfficiallySigned
            ? "微信 \(checkedInstallation.version) 已就绪。"
            : "微信 \(checkedInstallation.version) 已就绪，当前版本已被其他工具修改。"
        return .ready(detail)
    }

    func openAppManagementSettings() {
        let workspace = NSWorkspace.shared
        let privacySettingsURL = URL(
            string: "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_AppBundles"
        )
        if let privacySettingsURL, workspace.open(privacySettingsURL) {
            return
        }
        workspace.open(URL(fileURLWithPath: "/System/Applications/System Settings.app"))
    }

    private func refreshContent() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        installation = await launchService.installation()
        runningInstanceCount = launchService.runningInstanceCount()
        clones = await cloneService.clones()

        guard let installation else {
            compatibility = .unavailable(reason: "没有找到微信。", supportedBuilds: [])
            hasEnhancementBackup = false
            return
        }
        async let checkedCompatibility = enhancementService.compatibility(build: installation.build)
        async let backupAvailable = enhancementService.hasBackup(for: installation.build)
        compatibility = await checkedCompatibility
        hasEnhancementBackup = await backupAvailable
    }

    private func performUpdateAllClones() async {
        guard let installation else {
            message = UserMessage(title: "没有找到微信", detail: "请先安装微信。")
            return
        }
        let targets = outdatedClones.sorted { $0.index < $1.index }
        guard !targets.isEmpty else {
            message = UserMessage(title: "已经是最新版本", detail: "所有分身都是最新版本。")
            return
        }
        let runningTargets = targets.filter { launchService.isRunning(bundleIdentifier: $0.bundleIdentifier) }
        guard runningTargets.isEmpty else {
            message = UserMessage(
                title: "请先退出待更新分身",
                detail: "仍在运行：\(runningTargets.map(\.displayName).joined(separator: "、"))。"
            )
            return
        }

        isRunningCloneOperation = true
        cloneOperationProgress = 0
        defer {
            isRunningCloneOperation = false
            cloneOperationDescription = ""
        }

        var completedCount = 0
        for clone in targets {
            cloneOperationDescription = "正在更新 \(clone.displayName)…"
            do {
                _ = try await cloneService.update(clone, from: installation)
                completedCount += 1
                cloneOperationProgress = Double(completedCount) / Double(targets.count)
            } catch {
                await refreshContent()
                message = UserMessage(
                    title: "批量更新未完成",
                    detail: "已更新 \(completedCount) 个分身；\(clone.displayName) 更新失败：\(error.localizedDescription)"
                )
                return
            }
        }

        await refreshContent()
        message = UserMessage(
            title: "全部分身已更新",
            detail: "已更新到微信 \(installation.version)，登录数据保留。"
        )
    }

    private func performApplyClonePlan(_ plan: ClonePlan) async {
        guard let installation else {
            message = UserMessage(title: "没有找到微信", detail: "请先安装微信。")
            return
        }
        let items = Array(
            Dictionary(
                plan.items.filter { $0.index > 0 }.map { ($0.index, $0) },
                uniquingKeysWith: { first, _ in first }
            )
            .values
            .sorted { $0.index < $1.index }
            .prefix(20)
        )
        guard !items.isEmpty else {
            message = UserMessage(title: "方案内容无效", detail: "方案中没有可恢复的微信分身。")
            return
        }

        let clonesByIndex = Dictionary(
            clones.map { ($0.index, $0) },
            uniquingKeysWith: { preferred, _ in preferred }
        )
        let runningClones = items.compactMap { clonesByIndex[$0.index] }.filter {
            launchService.isRunning(bundleIdentifier: $0.bundleIdentifier)
        }
        guard runningClones.isEmpty else {
            message = UserMessage(
                title: "请先退出相关分身",
                detail: "仍在运行：\(runningClones.map(\.displayName).joined(separator: "、"))。"
            )
            return
        }

        isRunningCloneOperation = true
        cloneOperationProgress = 0
        defer {
            isRunningCloneOperation = false
            cloneOperationDescription = ""
        }

        var createdCount = 0
        var updatedCount = 0
        for (offset, item) in items.enumerated() {
            cloneOperationDescription = "正在应用 \(item.displayName)…"
            do {
                if let clone = clonesByIndex[item.index] {
                    let needsUpdate = !clone.isInstalledInApplicationsFolder
                        || clone.sourceBuild != installation.build
                        || clone.displayName != item.displayName
                    if needsUpdate {
                        _ = try await cloneService.update(
                            clone,
                            from: installation,
                            displayName: item.displayName
                        )
                        updatedCount += 1
                    }
                } else {
                    _ = try await cloneService.create(
                        index: item.index,
                        displayName: item.displayName,
                        from: installation
                    )
                    createdCount += 1
                }
                cloneOperationProgress = Double(offset + 1) / Double(items.count)
            } catch {
                await refreshContent()
                message = UserMessage(
                    title: "方案未完全应用",
                    detail: "已新建 \(createdCount) 个、更新 \(updatedCount) 个；\(item.displayName) 处理失败：\(error.localizedDescription)"
                )
                return
            }
        }

        await refreshContent()
        message = UserMessage(
            title: "方案已应用",
            detail: "已创建 \(createdCount) 个、更新 \(updatedCount) 个；其他分身不受影响。新 Mac 上需要重新登录。"
        )
    }

    private func performEnhancementInstall() async {
        guard let installation else {
            message = UserMessage(title: "没有找到微信", detail: "请先安装微信。")
            return
        }
        runningInstanceCount = launchService.runningInstanceCount()
        guard runningInstanceCount == 0 else {
            message = UserMessage(title: "请先退出微信", detail: "修改微信前必须退出全部微信实例。")
            return
        }

        do {
            try await enhancementService.install(
                installation: installation,
                options: selectedEnhancements
            )
            message = UserMessage(title: "增强已安装", detail: "已创建完整备份并重新签名微信。")
            await refreshContent()
        } catch {
            present(error: error, title: "安装增强失败")
        }
    }

    private func performRestore() async {
        guard let installation else { return }
        runningInstanceCount = launchService.runningInstanceCount()
        guard runningInstanceCount == 0 else {
            message = UserMessage(title: "请先退出微信", detail: "恢复备份前必须退出全部微信实例。")
            return
        }

        do {
            try await enhancementService.restore(installation: installation)
            message = UserMessage(title: "微信已恢复", detail: "已恢复腾讯原始签名的微信备份。")
            await refreshContent()
        } catch {
            present(error: error, title: "恢复失败")
        }
    }

    private func present(error: any Error, title: String) {
        message = UserMessage(title: title, detail: error.localizedDescription)
    }

    private func preparedCloneForLaunch(_ clone: WeChatClone) async throws -> WeChatClone {
        guard !clone.isInstalledInApplicationsFolder else { return clone }
        guard !launchService.isRunning(bundleIdentifier: clone.bundleIdentifier) else {
            throw AppError(message: "请先退出旧版分身，再打开一次以完成位置迁移。")
        }
        guard let installation else {
            throw AppError(message: "请先安装微信，才能修复分身。")
        }
        let migratedClone = try await cloneService.update(clone, from: installation)
        message = UserMessage(
            title: "分身已移到“应用程序”",
            detail: "已修复微信的安装位置提示，账号登录数据保持不变。"
        )
        return migratedClone
    }

    private func ensurePermissionGuideCompleted() -> Bool {
        guard permissionGuideStore.shouldPresentGuide else { return true }
        showsPermissionGuide = true
        return false
    }

    private func reloadClonePlans() {
        let result = clonePlanStore.load()
        clonePlans = result.plans
        isPlanCloudAvailable = result.cloudAvailable
    }
}
