import SwiftUI

struct EnhancementSafetyCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.standardSpacing) {
            Label("使用说明", systemImage: "lock.shield")
                .font(.headline)
            Text("仅支持已适配的微信版本，修改前会自动备份。普通多开和文件管理不受影响。")
                .foregroundStyle(.secondary)
        }
        .appCard()
    }
}
