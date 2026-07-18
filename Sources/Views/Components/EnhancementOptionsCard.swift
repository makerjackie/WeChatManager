import SwiftUI

struct EnhancementOptionsCard: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.standardSpacing) {
            Text("可选功能")
                .font(.headline)

            if case let .compatible(availableOptions) = model.compatibility {
                ForEach(EnhancementOption.allCases.filter { availableOptions.contains($0) }) { option in
                    EnhancementOptionRow(option: option)
                    if option != EnhancementOption.allCases.last {
                        Divider()
                    }
                }

                HStack {
                    Button("安装所选增强", systemImage: "wand.and.stars", action: model.requestEnhancementInstall)
                        .buttonStyle(.borderedProminent)
                        .disabled(model.selectedEnhancements.intersection(availableOptions).isEmpty)
                    if model.hasEnhancementBackup {
                        Button("恢复官方备份", systemImage: "arrow.uturn.backward", action: model.requestRestore)
                            .buttonStyle(.bordered)
                    }
                    Spacer()
                }
                .padding(.top, DesignTokens.compactSpacing)
            } else {
                ContentUnavailableView(
                    "当前没有可安装项",
                    systemImage: "shippingbox",
                    description: Text("不兼容时不会修改微信；普通多开启动和文件管理不受影响。")
                )
            }
        }
        .appCard()
    }
}
