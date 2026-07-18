import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        Form {
            Section("软件更新") {
                LabeledContent("当前版本", value: model.appVersionDescription)
                LabeledContent(
                    "自动检查",
                    value: model.updateController.automaticallyChecksForUpdates ? "已开启" : "未开启"
                )
                LabeledContent(
                    "自动安装",
                    value: model.updateController.automaticallyDownloadsUpdates ? "已开启" : "未开启"
                )
                Button(
                    "立即检查更新",
                    systemImage: "arrow.triangle.2.circlepath",
                    action: model.updateController.checkForUpdates
                )
                .disabled(!model.updateController.canCheckForUpdates)
            }

            Section("开源项目") {
                Button("查看源代码", systemImage: "chevron.left.forwardslash.chevron.right", action: model.openRepository)
                Button("查看 WeChatTweak 上游项目", systemImage: "link", action: model.openUpstreamRepository)
                LabeledContent("许可证", value: "GNU AGPL-3.0")
            }

            Section("隐私") {
                Label("微信文件仅在本机处理", systemImage: "internaldrive")
                Label("iCloud 只同步分身方案", systemImage: "icloud")
                Label("清理的缓存可从废纸篓恢复", systemImage: "trash")
                Button(
                    "查看权限说明",
                    systemImage: "hand.raised.fill",
                    action: model.showPermissionGuide
                )
                Button(
                    "打开“应用管理”设置",
                    systemImage: "gearshape.2",
                    action: model.openAppManagementSettings
                )
            }

            Section("使用边界") {
                Text("不连接或控制腾讯服务器。")
                    .foregroundStyle(.secondary)
                Text("本项目与腾讯、微信没有关联。")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("设置")
    }
}
