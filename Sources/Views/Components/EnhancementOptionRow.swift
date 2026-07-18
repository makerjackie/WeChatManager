import SwiftUI

struct EnhancementOptionRow: View {
    @Environment(AppModel.self) private var model
    let option: EnhancementOption

    var body: some View {
        HStack(spacing: DesignTokens.standardSpacing) {
            Button {
                model.toggleEnhancement(option)
            } label: {
                HStack(spacing: DesignTokens.standardSpacing) {
                    Image(systemName: option.systemImage)
                        .font(.title2)
                        .frame(width: 32)
                        .accessibilityHidden(true)
                    Text(option.title)
                        .font(.headline)
                    Spacer()
                    Image(
                        systemName: model.selectedEnhancements.contains(option)
                            ? "checkmark.circle.fill"
                            : "circle"
                    )
                    .font(.title2)
                    .foregroundStyle(model.selectedEnhancements.contains(option) ? Color.accentColor : .secondary)
                    .accessibilityHidden(true)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(option.title)，\(model.selectedEnhancements.contains(option) ? "已选择" : "未选择")")

            InfoButton(title: option.title, details: [option.detail])
        }
    }
}
