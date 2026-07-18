import SwiftUI

struct PermissionGuideView: View {
    @Environment(AppModel.self) private var model
    @State private var step = PermissionGuideStep.introduction
    @State private var applicationResult: PermissionGuideResult?
    @State private var fileResult: PermissionGuideResult?
    @State private var isRequesting = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
                    Text("权限说明与引导")
                        .font(.title2)
                        .bold()
                    Text("每一步都先解释用途，再由你决定是否允许。")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("稍后处理", action: model.deferPermissionGuide)
                    .disabled(isRequesting)
            }
            .padding(DesignTokens.contentPadding)

            PermissionGuideProgressView(selectedStep: step)
                .padding(.horizontal, DesignTokens.contentPadding)
                .padding(.bottom, DesignTokens.roomySpacing)

            Divider()

            Group {
                switch step {
                case .introduction:
                    PermissionGuideIntroductionView(
                        continueAction: showApplicationAccess
                    )
                case .applicationAccess:
                    PermissionGuideAccessView(
                        title: "读取微信应用信息",
                        subtitle: "用于确认微信来自腾讯，并按当前版本安全创建分身。",
                        systemPrompt: "macOS 可能提示“微信多开助手想要访问其他应用程序的内容”。",
                        reasons: [
                            "读取微信版本、构建号和代码签名",
                            "从本机官方微信创建独立分身",
                            "这一步不会修改或删除微信"
                        ],
                        result: applicationResult,
                        isRequesting: isRequesting,
                        requestAction: requestApplicationAccess,
                        backAction: showIntroduction,
                        continueAction: showFileAccess
                    )
                case .fileAccess:
                    PermissionGuideAccessView(
                        title: "读取微信文件目录",
                        subtitle: "用于把不同账号的文件整理成“微信号一、微信号二”。",
                        systemPrompt: "macOS 可能提示“微信多开助手想要访问其他应用的数据”。",
                        reasons: [
                            "只读取目录结构、文件类型和占用空间",
                            "不解析聊天数据库，不展示聊天内容",
                            "不上传文件名、账号信息或目录内容"
                        ],
                        result: fileResult,
                        isRequesting: isRequesting,
                        requestAction: requestFileAccess,
                        backAction: showApplicationAccess,
                        continueAction: showAppManagement
                    )
                case .appManagement:
                    PermissionGuideAppManagementView(
                        backAction: showFileAccess,
                        openSettingsAction: model.openAppManagementSettings,
                        completeAction: model.completePermissionGuide
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 700, idealWidth: 760, minHeight: 570)
        .interactiveDismissDisabled()
    }

    private func requestApplicationAccess() {
        guard !isRequesting else { return }
        isRequesting = true
        Task {
            applicationResult = await model.requestWeChatApplicationAccess()
            isRequesting = false
        }
    }

    private func requestFileAccess() {
        guard !isRequesting else { return }
        isRequesting = true
        Task {
            fileResult = await model.requestWeChatDataAccess()
            isRequesting = false
        }
    }

    private func showIntroduction() {
        step = .introduction
    }

    private func showApplicationAccess() {
        step = .applicationAccess
    }

    private func showFileAccess() {
        step = .fileAccess
    }

    private func showAppManagement() {
        step = .appManagement
    }
}
