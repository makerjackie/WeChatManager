import SwiftUI

struct ClonePrivacyCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.standardSpacing) {
            Label("分身说明", systemImage: "square.stack.3d.up")
                .font(.headline)
            Text("各分身独立登录；更新或移除分身不会删除聊天数据。")
                .foregroundStyle(.secondary)
        }
        .appCard()
    }
}
