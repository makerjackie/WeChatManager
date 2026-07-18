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
                        Text("更新或删除其他应用程序")
                            .font(.title2)
                            .bold()
                        Text("这项“应用管理”权限只会在真正修改应用时由 macOS 提醒，不会为了弹出权限框而提前改动任何软件。")
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: DesignTokens.standardSpacing) {
                        Label("什么时候会出现", systemImage: "bell.badge")
                            .font(.headline)
                        Text("首次创建、更新或移除微信分身，以及安装或恢复“兼容增强”时，系统可能先发送通知，再要求你在“隐私与安全性 → 应用管理”中允许微信多开助手。")
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: DesignTokens.standardSpacing) {
                        Label("允许后会做什么", systemImage: "checkmark.shield")
                            .font(.headline)
                        Label(
                            "只处理 /Applications/WeChat.app 和本应用创建的“微信分身”",
                            systemImage: "checkmark.circle"
                        )
                        Label("删除分身时只移入废纸篓，账号容器默认保留", systemImage: "checkmark.circle")
                        Label("不会在后台修改其他应用程序", systemImage: "xmark.circle")
                    }

                    VStack(alignment: .leading, spacing: DesignTokens.standardSpacing) {
                        Label("另外两类系统提示", systemImage: "person.badge.shield.checkmark")
                            .font(.headline)
                        Text("兼容增强需要管理员授权时，密码由 macOS 处理，本应用不会保存。分身首次使用摄像头、麦克风或通知时，权限由该微信分身单独向你请求。")
                            .foregroundStyle(.secondary)
                    }

                    Label(
                        "如果“应用管理”里暂时没有微信多开助手，先完成引导即可；第一次实际修改应用时，macOS 会把它加入列表。",
                        systemImage: "info.circle"
                    )
                    .foregroundStyle(.secondary)
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack {
                Button("返回", systemImage: "chevron.left", action: backAction)
                Spacer()
                Button("打开“应用管理”设置", systemImage: "gear", action: openSettingsAction)
                Button("完成引导", systemImage: "checkmark", action: completeAction)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(DesignTokens.contentPadding)
    }
}
