import SwiftUI

struct CloneUpdateCard: View {
    @Environment(AppModel.self) private var model
    @State private var showsUpdateConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.standardSpacing) {
            Label("分身版本", systemImage: statusImage)
                .font(.title2)
                .bold()

            if let installation = model.installation {
                if model.clones.isEmpty {
                    Text("当前官方微信为 \(installation.version)，创建分身后可在这里统一更新。")
                        .foregroundStyle(.secondary)
                } else if model.outdatedClones.isEmpty {
                    Text("全部 \(model.clones.count) 个分身都与官方微信 \(installation.version) 一致。")
                        .foregroundStyle(.secondary)
                } else {
                    Text("检测到官方微信为 \(installation.version)，有 \(model.outdatedClones.count) 个分身需要同步。")
                    Text("更新只替换分身应用代码，Bundle ID 和独立账号容器保持不变。")
                        .foregroundStyle(.secondary)

                    Button("一键更新全部分身", systemImage: "arrow.triangle.2.circlepath") {
                        showsUpdateConfirmation = true
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(model.isRunningCloneOperation)
                    .confirmationDialog(
                        "将全部分身同步到微信 \(installation.version)？",
                        isPresented: $showsUpdateConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("开始更新", action: model.updateAllClones)
                        Button("取消", role: .cancel) { }
                    } message: {
                        Text("请先退出待更新的分身。旧应用会移入废纸篓，登录状态和聊天数据容器不会删除。")
                    }
                }
            } else {
                Text("没有找到官方微信，请先安装到“应用程序”文件夹。")
                    .foregroundStyle(.secondary)
            }
        }
        .appCard()
    }

    private var statusImage: String {
        model.outdatedClones.isEmpty ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
    }
}
