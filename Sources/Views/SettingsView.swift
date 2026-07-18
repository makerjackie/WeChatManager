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
                    "自动下载并安装",
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
                Text("所有微信文件扫描都在本机完成。应用不上传文件名、聊天记录、账号信息或目录内容。")
                    .foregroundStyle(.secondary)
                Text("iCloud 只同步方案名称、分身数量、显示名称和来源版本，不同步聊天记录、登录状态或微信文件。")
                    .foregroundStyle(.secondary)
                Text("缓存清理只会把明确选择的缓存目录移入废纸篓，不会静默永久删除。")
                    .foregroundStyle(.secondary)
                Button(
                    "查看权限说明与引导",
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
                Text("本应用只管理用户本人 Mac 上的微信应用和本地文件，不连接、扫描或控制腾讯服务器。")
                    .foregroundStyle(.secondary)
                Text("本项目与腾讯、微信没有关联。使用分身或兼容增强前，请自行了解微信软件许可协议及账号规则。")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("设置")
    }
}
