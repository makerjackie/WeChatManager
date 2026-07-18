import SwiftUI

struct PlanSyncCard: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.standardSpacing) {
            Label(
                model.isPlanCloudAvailable ? "iCloud 同步已开启" : "仅保存在本机",
                systemImage: model.isPlanCloudAvailable ? "icloud.fill" : "externaldrive.fill"
            )
            .font(.headline)

            Text("只同步分身方案；聊天和登录信息不会上传，换 Mac 后需重新登录微信。")
                .foregroundStyle(.secondary)
        }
        .appCard()
    }
}
