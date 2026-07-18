import SwiftUI

struct WeChatStatusCard: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        Group {
            if let installation = model.installation {
                HStack(alignment: .center, spacing: DesignTokens.roomySpacing) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.green)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
                        Text("微信 \(installation.version)")
                            .font(.title2)
                            .bold()
                        Text("构建号 \(installation.build) · \(signatureDescription(installation))")
                            .foregroundStyle(.secondary)
                        Text(installation.applicationURL.path)
                            .font(.callout.monospaced())
                            .foregroundStyle(.tertiary)
                            .textSelection(.enabled)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: DesignTokens.compactSpacing) {
                        Text("\(model.runningInstanceCount)")
                            .font(.largeTitle)
                            .bold()
                        Text("运行实例")
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                ContentUnavailableView(
                    "没有找到微信",
                    systemImage: "bubble.left.and.exclamationmark.bubble.right",
                    description: Text("请先从微信官网下载并安装 macOS 版微信。")
                )
            }
        }
        .appCard()
    }

    private func signatureDescription(_ installation: WeChatInstallation) -> String {
        installation.isOfficiallySigned ? "腾讯官方签名" : "已修改或非官方签名"
    }
}
