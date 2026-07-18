import SwiftUI

struct PlanSyncCard: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        HStack(spacing: DesignTokens.standardSpacing) {
            Label(
                model.isPlanCloudAvailable ? "iCloud 同步已开启" : "仅保存在本机",
                systemImage: model.isPlanCloudAvailable ? "icloud.fill" : "externaldrive.fill"
            )
            .font(.headline)
            Spacer()
            InfoButton(
                title: "同步说明",
                details: [
                    "只同步分身数量和名称",
                    "不会上传聊天或登录信息",
                    "换 Mac 后需要重新登录微信"
                ]
            )
        }
        .appCard()
    }
}
