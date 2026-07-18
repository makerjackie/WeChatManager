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
                    Text("仅在构建号精确匹配时修改微信，并在修改前保存完整的官方备份。")
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
            Text("操作需要管理员密码，会修改微信并将其改为本机临时签名。微信升级后可能需要重新安装增强。")
        }
        .confirmationDialog(
            "恢复官方微信备份？",
            isPresented: $model.showsRestoreConfirmation,
            titleVisibility: .visible
        ) {
            Button("恢复备份", action: model.restoreOfficialWeChat)
            Button("取消", role: .cancel) { }
        } message: {
            Text("当前微信应用将被已校验的腾讯官方签名备份替换，不会触碰聊天数据。")
        }
    }
}
