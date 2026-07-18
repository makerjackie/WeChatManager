import SwiftUI

struct PermissionGuideIntroductionView: View {
    let continueAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.roomySpacing) {
            VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
                Label("先说明，再请求", systemImage: "hand.raised.fill")
                    .font(.title2)
                    .bold()
                Text("微信多开助手只请求完成功能所需的权限。所有授权都由 macOS 管理，你可以拒绝，也可以稍后重新查看本引导。")
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: DesignTokens.standardSpacing) {
                ForEach(PermissionGuideStep.allCases.dropFirst()) { step in
                    PermissionGuideOverviewRow(step: step)
                }
            }

            Label(
                "应用不会获取微信密码、登录令牌，也不会连接、扫描或控制腾讯服务器。",
                systemImage: "lock.shield.fill"
            )
            .foregroundStyle(.secondary)

            Spacer()

            HStack {
                Spacer()
                Button("开始权限引导", systemImage: "arrow.right", action: continueAction)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(DesignTokens.contentPadding)
    }
}
