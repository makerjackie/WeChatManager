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
                Text("微信 \(clone.sourceVersion)")
                    .foregroundStyle(.secondary)
                if !clone.isInstalledInApplicationsFolder {
                    Label("需要修复位置", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }
            }

            Spacer()

            if needsUpdate {
                Button(updateButtonTitle, systemImage: "arrow.triangle.2.circlepath", action: updateClone)
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
            Text("分身会移入废纸篓，聊天数据会保留。")
        }
    }

    private var needsUpdate: Bool {
        guard let installation = model.installation else { return false }
        return !clone.isInstalledInApplicationsFolder || clone.sourceBuild != installation.build
    }

    private var updateButtonTitle: String {
        clone.isInstalledInApplicationsFolder ? "更新" : "修复"
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
