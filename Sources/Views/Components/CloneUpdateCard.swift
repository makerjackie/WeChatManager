import SwiftUI

struct CloneUpdateCard: View {
    @Environment(AppModel.self) private var model
    @State private var showsUpdateConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.standardSpacing) {
            HStack {
                Label(statusTitle, systemImage: statusImage)
                    .font(.title2)
                    .bold()
                Spacer()
                InfoButton(title: "更新说明", details: updateDetails)
            }

            if model.installation != nil, !model.outdatedClones.isEmpty {
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
                }
            }
        }
        .appCard()
    }

    private var statusTitle: String {
        guard model.installation != nil else { return "请先安装微信" }
        guard !model.clones.isEmpty else { return "可以创建分身" }
        guard !model.outdatedClones.isEmpty else { return "分身已是最新" }
        return "\(model.outdatedClones.count) 个分身可更新"
    }

    private var statusImage: String {
        if model.installation == nil { return "exclamationmark.triangle.fill" }
        return model.outdatedClones.isEmpty ? "checkmark.circle.fill" : "arrow.triangle.2.circlepath"
    }

    private var updateDetails: [String] {
        var details = ["更新会保留登录和聊天数据", "更新前请退出对应分身"]
        if let installation = model.installation {
            details.insert("当前微信版本：\(installation.version)", at: 0)
        }
        return details
    }
}
