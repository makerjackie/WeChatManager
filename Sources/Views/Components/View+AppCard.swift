import SwiftUI

extension View {
    func appCard() -> some View {
        padding(DesignTokens.roomySpacing)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: DesignTokens.cardCornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: DesignTokens.cardCornerRadius)
                    .stroke(.quaternary)
            }
    }
}
