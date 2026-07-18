import SwiftUI

struct DashboardView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.roomySpacing) {
                PageHeader(
                    title: "微信多开助手",
                    infoTitle: "可以做什么",
                    infoDetails: [
                        "同时登录多个微信账号",
                        "快速找到微信文件",
                        "统一更新和恢复分身"
                    ]
                )

                WeChatStatusCard()
                CloneUpdateNotice()
                QuickActionsView()
                DashboardFileSummaryView()
            }
            .padding(DesignTokens.contentPadding)
            .frame(maxWidth: 920, alignment: .leading)
        }
        .navigationTitle("总览")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("刷新", systemImage: "arrow.clockwise", action: model.refresh)
                    .disabled(model.isRefreshing)
            }
        }
    }
}
