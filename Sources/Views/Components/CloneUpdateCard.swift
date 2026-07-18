import SwiftUI

struct CloneUpdateCard: View {
    @Environment(AppModel.self) private var model
    @State private var showsUpdateConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.standardSpacing) {
            Label("分身更新", systemImage: statusImage)
                .font(.title2)
                .bold()

            if let installation = model.installation {
                if model.clones.isEmpty {
                    Text("微信 \(installation.version) 已就绪。")
                        .foregroundStyle(.secondary)
                } else if model.outdatedClones.isEmpty {
                    Text("\(model.clones.count) 个分身都是最新版本。")
                        .foregroundStyle(.secondary)
                } else {
                    Text("有 \(model.outdatedClones.count) 个分身可更新到微信 \(installation.version)。")
                    Text("更新后保留登录状态和聊天数据。")
                        .foregroundStyle(.secondary)

                    Button("全部更新", systemImage: "arrow.triangle.2.circlepath") {
                        showsUpdateConfirmation = true
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(model.isRunningCloneOperation)
                    .confirmationDialog(
                        "更新 \(model.outdatedClones.count) 个分身？",
                        isPresented: $showsUpdateConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("开始更新", action: model.updateAllClones)
                        Button("取消", role: .cancel) { }
                    } message: {
                        Text("请先退出这些分身。旧版本会移入废纸篓。")
                    }
                }
            } else {
                Text("没有找到微信，请先安装微信。")
                    .foregroundStyle(.secondary)
            }
        }
        .appCard()
    }

    private var statusImage: String {
        model.outdatedClones.isEmpty ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
    }
}
