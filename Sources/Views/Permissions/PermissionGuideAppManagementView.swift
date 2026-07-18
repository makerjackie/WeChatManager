import SwiftUI

struct PermissionGuideAppManagementView: View {
    let backAction: () -> Void
    let completeAction: () -> Void

    var body: some View {
        VStack(spacing: DesignTokens.roomySpacing) {
            Spacer()

            Image(systemName: "gearshape.2.fill")
                .font(.system(.largeTitle, design: .rounded, weight: .regular))
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)

            HStack(alignment: .firstTextBaseline) {
                Text("最后一步")
                    .font(.title2)
                    .bold()
                InfoButton(
                    title: "应用管理说明",
                    details: [
                        "只管理微信和本应用创建的分身",
                        "移除分身不会删除聊天数据",
                        "兼容增强会单独请求管理员授权"
                    ]
                )
            }

            Text("创建分身时，请在系统提示中选择“允许”。")
                .foregroundStyle(.secondary)

            Spacer()

            HStack {
                Button("返回", systemImage: "chevron.left", action: backAction)
                Spacer()
                Button("完成", systemImage: "checkmark", action: completeAction)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(DesignTokens.contentPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
