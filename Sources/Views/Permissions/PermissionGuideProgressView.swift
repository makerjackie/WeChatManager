import SwiftUI

struct PermissionGuideProgressView: View {
    let selectedStep: PermissionGuideStep

    var body: some View {
        HStack(spacing: DesignTokens.compactSpacing) {
            ForEach(PermissionGuideStep.allCases) { step in
                VStack(spacing: DesignTokens.compactSpacing) {
                    Image(systemName: step.systemImage)
                        .frame(width: 28, height: 28)
                        .background(.quaternary, in: Circle())
                    Text(step.title)
                        .font(.callout)
                }
                .foregroundStyle(step.rawValue <= selectedStep.rawValue ? Color.accentColor : .secondary)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(step.title)
                .accessibilityValue(step == selectedStep ? "当前步骤" : "")

                if step != .appManagement {
                    Divider()
                        .frame(height: 44)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
