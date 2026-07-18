import SwiftUI

struct CompatibleVersionGuideCard: View {
    let supportedBuilds: [String]

    private let release = CompatibleWeChatRelease.recommended

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.standardSpacing) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
                    Text("推荐版本")
                        .font(.headline)
                    Text(release.displayName)
                        .font(.title3)
                        .bold()
                }
                Spacer()
                InfoButton(title: "可用版本", details: versionDetails)
            }

            Text("下载后退出微信，完成安装，再回到这里重新检查。")
                .foregroundStyle(.secondary)

            HStack {
                Link(destination: release.officialDownloadURL) {
                    Label("腾讯官方下载", systemImage: "arrow.down.circle")
                }
                .buttonStyle(.borderedProminent)

                Link(destination: release.archiveReleaseURL) {
                    Label("备用下载", systemImage: "clock.arrow.circlepath")
                }
                .buttonStyle(.bordered)
            }
        }
        .appCard()
    }

    private var versionDetails: [String] {
        var details = supportedBuilds.map { CompatibleWeChatRelease.label(for: $0) }
        details.append("推荐版本校验值：\(release.sha256)")
        details.append("优先使用腾讯官方下载；失效时再用备用下载")
        return details
    }
}
