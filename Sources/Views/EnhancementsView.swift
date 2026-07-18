import SwiftUI

struct EnhancementsView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.roomySpacing) {
                VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
                    Text("兼容增强")
                        .font(.largeTitle)
                        .bold()
                    Text("修改前自动备份，仅支持已适配的微信版本。")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                CompatibilityCard()
                EnhancementOptionsCard()
                EnhancementSafetyCard()
            }
            .padding(DesignTokens.contentPadding)
            .frame(maxWidth: 860, alignment: .leading)
        }
        .navigationTitle("兼容增强")
        .confirmationDialog(
            "安装所选增强？",
            isPresented: $model.showsInstallConfirmation,
            titleVisibility: .visible
        ) {
            Button("创建备份并安装", action: model.installEnhancements)
            Button("取消", role: .cancel) { }
        } message: {
            Text("需要管理员授权，安装前会自动备份微信。")
        }
        .confirmationDialog(
            "恢复微信备份？",
            isPresented: $model.showsRestoreConfirmation,
            titleVisibility: .visible
        ) {
            Button("恢复备份", action: model.restoreOfficialWeChat)
            Button("取消", role: .cancel) { }
        } message: {
            Text("将恢复之前保存的微信，不影响聊天数据。")
        }
    }
}
