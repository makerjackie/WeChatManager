import SwiftUI

struct PermissionGuideProgressView: View {
    let selectedStep: PermissionGuideStep

    var body: some View {
        HStack(spacing: DesignTokens.standardSpacing) {
            ProgressView(
                value: Double(selectedStep.rawValue),
                total: Double(PermissionGuideStep.allCases.count - 1)
            )
            Text("\(selectedStep.rawValue) / \(PermissionGuideStep.allCases.count - 1)")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .accessibilityLabel("权限设置进度")
        .accessibilityValue("第 \(selectedStep.rawValue) 步，共 \(PermissionGuideStep.allCases.count - 1) 步")
    }
}
