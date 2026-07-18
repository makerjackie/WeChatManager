import SwiftUI

struct WeChatStatusCard: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        Group {
            if let installation = model.installation {
                HStack(alignment: .center, spacing: DesignTokens.roomySpacing) {
                    Image(systemName: "app.fill")
                        .font(.largeTitle)
                        .foregroundStyle(Color.accentColor)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
                        Text("微信 \(installation.version)")
                            .font(.title2)
                            .bold()
                        Text(signatureDescription(installation))
                            .foregroundStyle(.secondary)
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
                    systemImage: "app.badge",
                    description: Text("请先从微信官网下载并安装 macOS 版微信。")
                )
            }
        }
        .appCard()
    }

    private func signatureDescription(_ installation: WeChatInstallation) -> String {
        installation.isOfficiallySigned ? "腾讯官方版本" : "当前微信已被其他工具修改"
    }
}
