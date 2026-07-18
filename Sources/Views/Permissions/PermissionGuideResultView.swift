import SwiftUI

struct PermissionGuideResultView: View {
    let result: PermissionGuideResult

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
                Text(result.title)
                    .font(.headline)
                Text(result.detail)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: result.systemImage)
                .foregroundStyle(resultColor)
        }
        .padding(DesignTokens.standardSpacing)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(resultColor.opacity(0.1), in: RoundedRectangle(cornerRadius: DesignTokens.cardCornerRadius))
    }

    private var resultColor: Color {
        switch result {
        case .ready: .green
        case .unavailable: .blue
        case .needsAction: .orange
        }
    }
}
