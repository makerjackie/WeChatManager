import SwiftUI

struct PermissionGuideOverviewRow: View {
    let step: PermissionGuideStep

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.standardSpacing) {
            Image(systemName: step.systemImage)
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(width: 32)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
                Text(step.title)
                    .font(.headline)
                Text(step.summary)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(DesignTokens.standardSpacing)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: DesignTokens.cardCornerRadius))
    }
}
