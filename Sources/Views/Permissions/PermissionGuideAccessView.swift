import SwiftUI

struct PermissionGuideAccessView: View {
    let title: String
    let systemImage: String
    let infoTitle: String
    let infoDetails: [String]
    let result: PermissionGuideResult?
    let isRequesting: Bool
    let backAction: () -> Void
    let nextAction: () -> Void

    var body: some View {
        VStack(spacing: DesignTokens.roomySpacing) {
            Spacer()

            Image(systemName: systemImage)
                .font(.system(.largeTitle, design: .rounded, weight: .regular))
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)

            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.title2)
                    .bold()
                InfoButton(title: infoTitle, details: infoDetails)
            }

            Text("按系统提示选择“允许”。")
                .foregroundStyle(.secondary)

            if let result {
                PermissionGuideResultView(result: result)
            }

            Spacer()

            HStack {
                Button("返回", systemImage: "chevron.left", action: backAction)
                Spacer()
                Button(
                    isRequesting ? "等待确认" : (result?.canContinue == false ? "重试" : "下一步"),
                    systemImage: "arrow.right",
                    action: nextAction
                )
                .disabled(isRequesting)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(DesignTokens.contentPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
