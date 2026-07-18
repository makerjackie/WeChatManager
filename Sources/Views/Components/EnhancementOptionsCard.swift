import SwiftUI

struct EnhancementOptionsCard: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.standardSpacing) {
            Text("选择功能")
                .font(.headline)

            if case let .compatible(availableOptions, _) = model.compatibility {
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
                    "暂无可用功能",
                    systemImage: "shippingbox"
                )
            }
        }
        .appCard()
    }
}
