import SwiftUI

struct PermissionGuideResultView: View {
    let result: PermissionGuideResult

    var body: some View {
        HStack {
            Label(result.title, systemImage: result.systemImage)
                .font(.headline)
                .foregroundStyle(resultColor)
            Spacer()
            InfoButton(title: result.title, details: [result.detail])
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
