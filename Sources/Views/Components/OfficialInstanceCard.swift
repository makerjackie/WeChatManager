import SwiftUI

struct OfficialInstanceCard: View {
    @Environment(AppModel.self) private var model
    let installation: WeChatInstallation

    var body: some View {
        HStack(spacing: DesignTokens.standardSpacing) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title)
                .foregroundStyle(.green)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
                Text("官方微信")
                    .font(.headline)
                Text("版本 \(installation.version)（\(installation.build)）· 腾讯官方签名")
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("启动", systemImage: "play.fill", action: model.launchOfficial)
                .buttonStyle(.borderedProminent)
        }
        .appCard()
    }
}
