import SwiftUI

struct DashboardView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.roomySpacing) {
                VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
                    Text("微信，一目了然")
                        .font(.largeTitle)
                        .bold()
                    Text("多开、文件定位、缓存管理和版本增强都集中在这里。")
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
