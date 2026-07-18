import SwiftUI

struct DashboardView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.roomySpacing) {
                VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
                    Text("微信多开助手")
                        .font(.largeTitle)
                        .bold()
                    Text("多开、文件和更新，都在这里。")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

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
