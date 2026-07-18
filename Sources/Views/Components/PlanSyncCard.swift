import SwiftUI

struct PlanSyncCard: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.standardSpacing) {
            Label(
                model.isPlanCloudAvailable ? "iCloud 方案同步可用" : "当前仅保存到本机",
                systemImage: model.isPlanCloudAvailable ? "icloud.fill" : "externaldrive.fill"
            )
            .font(.headline)

            Text("同步内容仅包括方案名称、分身序号、显示名称和来源版本，不包含微信聊天、登录状态、文件路径或账号标识。")
                .foregroundStyle(.secondary)
            Text("在新 Mac 安装官方微信后应用方案，即可重建相同数量的分身；微信账号需要重新扫码登录。")
                .foregroundStyle(.secondary)
        }
        .appCard()
    }
}
