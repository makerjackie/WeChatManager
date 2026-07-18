import SwiftUI

struct SidebarStatusView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
            Label(
                model.installation == nil ? "未找到微信" : "微信已就绪",
                systemImage: model.installation == nil ? "exclamationmark.triangle" : "checkmark.circle.fill"
            )
            .foregroundStyle(model.installation == nil ? .orange : .green)
            .accessibilityLabel(model.installation == nil ? "未找到微信" : "微信已就绪")

            Text("正在运行 \(model.runningInstanceCount) 个实例")
                .foregroundStyle(.secondary)
        }
        .font(.callout)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
