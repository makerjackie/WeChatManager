import SwiftUI

struct PermissionGuideIntroductionView: View {
    let continueAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.roomySpacing) {
            VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
                Label("只请求必要权限", systemImage: "hand.raised.fill")
                    .font(.title2)
                    .bold()
                Text("授权由 macOS 管理，可随时更改。")
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: DesignTokens.standardSpacing) {
                ForEach(PermissionGuideStep.allCases.dropFirst()) { step in
                    PermissionGuideOverviewRow(step: step)
                }
            }

            Label(
                "不读取微信密码或聊天内容。",
                systemImage: "lock.shield.fill"
            )
            .foregroundStyle(.secondary)

            Spacer()

            HStack {
                Spacer()
                Button("开始", systemImage: "arrow.right", action: continueAction)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(DesignTokens.contentPadding)
    }
}
