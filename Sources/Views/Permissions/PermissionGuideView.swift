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
                    Text("权限引导")
                        .font(.title2)
                        .bold()
                    Text("需要时再由 macOS 请求。")
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
                        title: "读取微信应用",
                        subtitle: "用于识别当前微信并创建分身。",
                        systemPrompt: "macOS 会询问是否允许访问微信。",
                        reasons: [
                            "读取版本信息",
                            "创建和更新分身",
                            "不会修改原微信"
                        ],
                        result: applicationResult,
                        isRequesting: isRequesting,
                        requestAction: requestApplicationAccess,
                        backAction: showIntroduction,
                        continueAction: showFileAccess
                    )
                case .fileAccess:
                    PermissionGuideAccessView(
                        title: "读取微信文件",
                        subtitle: "用于按账号整理文件。",
                        systemPrompt: "macOS 会询问是否允许访问微信数据。",
                        reasons: [
                            "查找文件并计算占用",
                            "不读取或上传聊天内容"
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
        .frame(minWidth: 680, idealWidth: 740, minHeight: 520)
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
