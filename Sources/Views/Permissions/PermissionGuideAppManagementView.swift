import SwiftUI

struct PermissionGuideAppManagementView: View {
    let backAction: () -> Void
    let openSettingsAction: () -> Void
    let completeAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.roomySpacing) {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.roomySpacing) {
                    VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
                        Text("允许管理分身")
                            .font(.title2)
                            .bold()
                        Text("创建、更新或移除分身时，macOS 会要求你允许。")
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: DesignTokens.standardSpacing) {
                        Label("只处理微信和本应用创建的分身", systemImage: "checkmark.circle")
                        Label("移除分身时保留聊天数据", systemImage: "checkmark.circle")
                        Label("兼容增强会单独请求管理员授权", systemImage: "checkmark.circle")
                    }

                    Label(
                        "未使用这些功能时，不会修改其他应用。",
                        systemImage: "lock.shield"
                    )
                    .foregroundStyle(.secondary)
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack {
                Button("返回", systemImage: "chevron.left", action: backAction)
                Spacer()
                Button("打开系统设置", systemImage: "gear", action: openSettingsAction)
                Button("完成", systemImage: "checkmark", action: completeAction)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(DesignTokens.contentPadding)
    }
}
