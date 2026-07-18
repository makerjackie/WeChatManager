import SwiftUI

struct PermissionGuideIntroductionView: View {
    let continueAction: () -> Void

    var body: some View {
        VStack(spacing: DesignTokens.roomySpacing) {
            Spacer()

            Image(systemName: "hand.raised.fill")
                .font(.system(.largeTitle, design: .rounded, weight: .regular))
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)

            Text("只需三步")
                .font(.title2)
                .bold()

            Text("按“下一步”完成设置。")
            .foregroundStyle(.secondary)

            Spacer()

            HStack {
                Spacer()
                Button("下一步", systemImage: "arrow.right", action: continueAction)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(DesignTokens.contentPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
