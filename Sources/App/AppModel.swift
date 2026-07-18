import AppKit
import Foundation
import Observation

@MainActor
@Observable
final class AppModel {
    var selectedPage: NavigationPage? = .overview
    var installation: WeChatInstallation?
    var runningInstanceCount = 0
    var storageLocations: [StorageLocation] = []
    var clones: [WeChatClone] = []
    var storageSearchText = ""
    var accountAliases: [String: String] = [:]
    var selectedCacheIDs = Set<String>()
    var isRefreshing = false
    var isCalculatingSizes = false
    var isCreatingClone = false
    var sizeScanProgress = 0.0
    var compatibility: EnhancementCompatibility = .checking
    var selectedEnhancements: Set<EnhancementOption> = [.multiInstance]
    var hasEnhancementBackup = false
    var message: UserMessage?
    var showsCleanupConfirmation = false
    var showsInstallConfirmation = false
    var showsRestoreConfirmation = false
    var showsPermissionGuide = false

    let updateController = UpdateController()

    @ObservationIgnored
    private let launchService = WeChatLaunchService()
    @ObservationIgnored
    private let dataLocator = WeChatDataLocator()
    @ObservationIgnored
    private let storageScanner = StorageScanner()
    @ObservationIgnored
    private let cloneService = WeChatCloneService()
    @ObservationIgnored
    private let enhancementService = EnhancementService()
    @ObservationIgnored
    private let accountNameStore: AccountNameStore
    @ObservationIgnored
    private let permissionGuideStore: PermissionGuideStore
    @ObservationIgnored
    private var sizeScanTask: Task<Void, Never>?

    init(
        accountNameStore: AccountNameStore = AccountNameStore(),
        permissionGuideStore: PermissionGuideStore = PermissionGuideStore()
    ) {
        self.accountNameStore = accountNameStore
        self.permissionGuideStore = permissionGuideStore
    }

    var visibleStorageAccountGroups: [StorageAccountGroup] {
        var seenIdentifiers = Set<String>()
        let identifiers = storageLocations.compactMap(\.accountIdentifier).filter {
            seenIdentifiers.insert($0).inserted
        }

        return identifiers.enumerated().compactMap { offset, identifier in
            let defaultName = StorageAccountGroup.defaultName(for: offset + 1)
            let displayName = accountAliases[identifier] ?? defaultName
            let locations = storageLocations.filter { $0.accountIdentifier == identifier }
            let visibleLocations: [StorageLocation]
            if storageSearchText.isEmpty
                || displayName.localizedStandardContains(storageSearchText) {
                visibleLocations = locations
            } else {
                visibleLocations = locations.filter(matchesStorageSearch)
            }
            guard !visibleLocations.isEmpty else { return nil }
            return StorageAccountGroup(
                id: identifier,
                displayName: displayName,
                defaultName: defaultName,
                locations: visibleLocations
            )
        }
    }

    var visibleAdditionalStorageLocations: [StorageLocation] {
        let locations = storageLocations.filter { $0.accountIdentifier == nil }
        guard !storageSearchText.isEmpty else { return locations }
        return locations.filter(matchesStorageSearch)
    }

    var hasVisibleStorageLocations: Bool {
        !visibleStorageAccountGroups.isEmpty || !visibleAdditionalStorageLocations.isEmpty
    }

    var selectedCacheCount: Int {
        selectedCacheIDs.count
    }

    var appVersionDescription: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "未知"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "未知"
        return "版本 \(version)（\(build)）"
    }

    func start() async {
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
                        throw AppError(message: "请先安装官方微信。")
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

    func calculateStorageSizes() {
        guard !isCalculatingSizes else { return }
        sizeScanTask?.cancel()
        sizeScanTask = Task { await performSizeScan() }
    }

    func cancelStorageScan() {
        sizeScanTask?.cancel()
        sizeScanTask = nil
        isCalculatingSizes = false
    }

    func toggleCacheSelection(_ location: StorageLocation) {
        if selectedCacheIDs.contains(location.id) {
            selectedCacheIDs.remove(location.id)
        } else {
            selectedCacheIDs.insert(location.id)
        }
    }

    func requestCleanup() {
        guard !selectedCacheIDs.isEmpty else {
            message = UserMessage(title: "尚未选择缓存", detail: "请先勾选要移入废纸篓的缓存目录。")
            return
        }
        showsCleanupConfirmation = true
    }

    func cleanSelectedCaches() {
        Task { await performCleanup() }
    }

    func open(_ location: StorageLocation) {
        NSWorkspace.shared.open(location.url)
    }

    func copyPath(of location: StorageLocation) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(location.url.path, forType: .string)
        message = UserMessage(title: "已复制路径", detail: location.url.path)
    }

    func renameAccount(identifier: String, name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            message = UserMessage(title: "名称不能为空", detail: "请输入一个容易辨认的账号名称。")
            return
        }
        accountAliases[identifier] = trimmedName
        accountNameStore.setName(trimmedName, for: identifier)
    }

    func resetAccountName(identifier: String) {
        accountAliases.removeValue(forKey: identifier)
        accountNameStore.setName(nil, for: identifier)
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
                message = UserMessage(title: "没有找到微信", detail: "请先安装官方微信。")
                return
            }
            isCreatingClone = true
            defer { isCreatingClone = false }
            do {
                let clone = try await cloneService.createNext(from: installation)
                message = UserMessage(title: "分身已创建", detail: "已创建 \(clone.displayName)，登录后即可独立使用。")
                await refreshContent()
            } catch {
                present(error: error, title: "创建分身失败")
            }
        }
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
                message = UserMessage(title: "分身已更新", detail: "登录数据保留，应用代码已更新到微信 \(installation.version)。")
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
                message = UserMessage(title: "分身已移入废纸篓", detail: "账号容器数据没有删除，可从废纸篓恢复应用。")
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
        let signatureDescription = checkedInstallation.isOfficiallySigned
            ? "腾讯官方签名"
            : "当前不是腾讯官方签名"
        return .ready(
            "已读取微信 \(checkedInstallation.version) 的版本与签名信息（\(signatureDescription)）。"
        )
    }

    func requestWeChatDataAccess() async -> PermissionGuideResult {
        let scan = await dataLocator.scan()
        applyStorageLocations(scan.locations)

        switch scan.accessState {
        case .available:
            let accountCount = Set(scan.locations.compactMap(\.accountIdentifier)).count
            let detail = accountCount == 0
                ? "权限已可用；当前尚未发现已登录的微信账号。"
                : "权限已可用，已识别 \(accountCount) 个本机微信账号目录。"
            return .ready(detail)
        case .notFound:
            return .unavailable("当前尚未生成微信文件目录；登录微信并收发一次文件后再刷新即可。")
        case .unavailable:
            return .needsAction("系统尚未允许读取微信文件。请在系统提示中选择“允许”，然后重试。")
        }
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
        applyStorageLocations(await dataLocator.locations())

        guard let installation else {
            compatibility = .unavailable(reason: "没有找到微信，兼容增强不可用。")
            hasEnhancementBackup = false
            return
        }
        async let checkedCompatibility = enhancementService.compatibility(build: installation.build)
        async let backupAvailable = enhancementService.hasBackup(for: installation.build)
        compatibility = await checkedCompatibility
        hasEnhancementBackup = await backupAvailable
    }

    private func performSizeScan() async {
        isCalculatingSizes = true
        sizeScanProgress = 0
        defer {
            isCalculatingSizes = false
            sizeScanTask = nil
        }

        let locations = storageLocations
        guard !locations.isEmpty else { return }
        for (index, location) in locations.enumerated() {
            guard !Task.isCancelled else { return }
            do {
                let size = try await storageScanner.allocatedSize(of: location.url)
                if let currentIndex = storageLocations.firstIndex(where: { $0.id == location.id }) {
                    storageLocations[currentIndex] = location.withAllocatedSize(size)
                }
            } catch is CancellationError {
                return
            } catch {
                continue
            }
            sizeScanProgress = Double(index + 1) / Double(locations.count)
        }
    }

    private func performCleanup() async {
        runningInstanceCount = launchService.runningInstanceCount()
        guard runningInstanceCount == 0 else {
            message = UserMessage(title: "请先退出微信", detail: "为避免缓存仍在写入，请退出全部微信实例后再清理。")
            return
        }

        let targets = storageLocations
            .filter { selectedCacheIDs.contains($0.id) && $0.isCache }
            .map(\.url)
        do {
            let allowedCacheRoots = await dataLocator.allowedCacheRoots()
            let cleaner = try CacheCleaner(allowedRoots: allowedCacheRoots)
            let result = try await cleaner.clean(urls: targets)
            selectedCacheIDs.removeAll()
            applyStorageLocations(await dataLocator.locations())
            message = UserMessage(
                title: "缓存已移入废纸篓",
                detail: "已处理 \(result.movedItemCount) 个目录，可从废纸篓恢复。"
            )
        } catch {
            present(error: error, title: "缓存清理失败")
        }
    }

    private func performEnhancementInstall() async {
        guard let installation else {
            message = UserMessage(title: "没有找到微信", detail: "请先安装官方微信。")
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
            throw AppError(message: "请先安装官方微信，才能迁移旧版分身。")
        }
        let migratedClone = try await cloneService.update(clone, from: installation)
        message = UserMessage(
            title: "分身已移到“应用程序”",
            detail: "已修复微信的安装位置提示，账号登录数据保持不变。"
        )
        return migratedClone
    }

    private func matchesStorageSearch(_ location: StorageLocation) -> Bool {
        location.title.localizedStandardContains(storageSearchText)
            || location.detail.localizedStandardContains(storageSearchText)
            || location.url.path.localizedStandardContains(storageSearchText)
    }

    private func applyStorageLocations(_ locations: [StorageLocation]) {
        storageLocations = locations
        let accountIdentifiers = Array(Set(locations.compactMap(\.accountIdentifier)))
        accountAliases = accountNameStore.names(for: accountIdentifiers)
        selectedCacheIDs.formIntersection(Set(locations.filter(\.isCache).map(\.id)))
    }

    private func ensurePermissionGuideCompleted() -> Bool {
        guard permissionGuideStore.shouldPresentGuide else { return true }
        showsPermissionGuide = true
        return false
    }
}
