import SwiftUI

struct EnhancementsView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.roomySpacing) {
                PageHeader(
                    title: "兼容增强",
                    infoTitle: "使用前须知",
                    infoDetails: [
                        "仅支持已适配的微信版本",
                        "目前仅支持 Apple 芯片 Mac",
                        "安装前会自动备份微信",
                        "普通多开和文件管理不受影响"
                    ]
                )

                CompatibilityCard()
                switch model.compatibility {
                case .compatible:
                    EnhancementOptionsCard()
                case let .unavailable(_, supportedBuilds):
                    if supportedBuilds.contains(CompatibleWeChatRelease.recommended.build) {
                        CompatibleVersionGuideCard(supportedBuilds: supportedBuilds)
                    }
                case .checking:
                    EmptyView()
                }
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
        }
        .confirmationDialog(
            "恢复微信备份？",
            isPresented: $model.showsRestoreConfirmation,
            titleVisibility: .visible
        ) {
            Button("恢复备份", action: model.restoreOfficialWeChat)
            Button("取消", role: .cancel) { }
        }
    }
}
