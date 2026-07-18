import SwiftUI

struct OfficialInstanceCard: View {
    @Environment(AppModel.self) private var model
    let installation: WeChatInstallation

    var body: some View {
        HStack(spacing: DesignTokens.standardSpacing) {
            Image(systemName: installation.isOfficiallySigned ? "checkmark.seal.fill" : "pencil.and.outline")
                .font(.title)
                .foregroundStyle(installation.isOfficiallySigned ? Color.green : Color.orange)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
                Text("微信")
                    .font(.headline)
                Text("当前安装")
                    .foregroundStyle(.secondary)
            }
            Spacer()
            InfoButton(
                title: "微信详情",
                details: ["版本：\(installation.version)", versionDescription]
            )
            Button("启动", systemImage: "play.fill", action: model.launchOfficial)
                .buttonStyle(.borderedProminent)
        }
        .appCard()
    }

    private var versionDescription: String {
        installation.isOfficiallySigned ? "腾讯官方版本" : "已被其他工具修改"
    }
}
