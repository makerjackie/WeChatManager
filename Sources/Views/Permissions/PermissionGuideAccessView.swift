import SwiftUI

struct PermissionGuideAccessView: View {
    let title: String
    let subtitle: String
    let systemPrompt: String
    let reasons: [String]
    let result: PermissionGuideResult?
    let isRequesting: Bool
    let requestAction: () -> Void
    let backAction: () -> Void
    let continueAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.roomySpacing) {
            VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
                Text(title)
                    .font(.title2)
                    .bold()
                Text(subtitle)
                    .foregroundStyle(.secondary)
            }

            Label(systemPrompt, systemImage: "macwindow.badge.plus")
                .padding(DesignTokens.standardSpacing)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: DesignTokens.cardCornerRadius))

            VStack(alignment: .leading, spacing: DesignTokens.standardSpacing) {
                Text("为什么需要")
                    .font(.headline)
                ForEach(reasons, id: \.self) { reason in
                    Label(reason, systemImage: "checkmark.circle")
                }
            }

            if let result {
                PermissionGuideResultView(result: result)
            }

            Spacer()

            HStack {
                Button("返回", systemImage: "chevron.left", action: backAction)
                Spacer()
                Button(
                    isRequesting ? "等待系统确认" : "请求此权限",
                    systemImage: "lock.open",
                    action: requestAction
                )
                .disabled(isRequesting)
                Button("继续", systemImage: "arrow.right", action: continueAction)
                    .buttonStyle(.borderedProminent)
                    .disabled(isRequesting || result == nil)
            }
        }
        .padding(DesignTokens.contentPadding)
    }
}
