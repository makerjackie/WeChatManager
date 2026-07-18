import SwiftUI

struct ManagedCloneRow: View {
    @Environment(AppModel.self) private var model
    @State private var showsDeleteConfirmation = false
    let clone: WeChatClone

    var body: some View {
        HStack(spacing: DesignTokens.standardSpacing) {
            Image(systemName: model.isRunning(clone) ? "square.stack.3d.up.fill" : "square.stack.3d.up")
                .font(.title)
                .foregroundStyle(model.isRunning(clone) ? Color.green : Color.accentColor)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
                HStack {
                    Text(clone.displayName)
                        .font(.headline)
                    Text(model.isRunning(clone) ? "运行中" : "未运行")
                        .foregroundStyle(model.isRunning(clone) ? .green : .secondary)
                }
                Text("来源：微信 \(clone.sourceVersion)（\(clone.sourceBuild)）")
                    .foregroundStyle(.secondary)
                Text(clone.applicationURL.path)
                    .font(.callout.monospaced())
                    .foregroundStyle(.tertiary)
                    .textSelection(.enabled)
            }

            Spacer()

            if needsUpdate {
                Button("更新分身", systemImage: "arrow.triangle.2.circlepath", action: updateClone)
            }
            Button("启动", systemImage: "play.fill", action: launchClone)
                .buttonStyle(.borderedProminent)
                .disabled(model.isRunning(clone))
            Menu("更多操作", systemImage: "ellipsis.circle") {
                Button("在访达中显示", systemImage: "finder", action: revealClone)
                Button("移入废纸篓", systemImage: "trash", role: .destructive) {
                    showsDeleteConfirmation = true
                }
            }
            .labelStyle(.iconOnly)
            .menuStyle(.borderlessButton)
        }
        .appCard()
        .confirmationDialog(
            "将 \(clone.displayName) 移入废纸篓？",
            isPresented: $showsDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("移入废纸篓", role: .destructive, action: deleteClone)
            Button("取消", role: .cancel) { }
        } message: {
            Text("只移动分身应用，不删除独立的微信账号容器数据。")
        }
    }

    private var needsUpdate: Bool {
        guard let installation = model.installation else { return false }
        return clone.sourceBuild != installation.build
    }

    private func launchClone() {
        model.launch(clone)
    }

    private func revealClone() {
        model.reveal(clone)
    }

    private func updateClone() {
        model.update(clone)
    }

    private func deleteClone() {
        model.moveToTrash(clone)
    }
}
