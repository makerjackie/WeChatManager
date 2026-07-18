import SwiftUI

struct PermissionGuideView: View {
    @Environment(AppModel.self) private var model
    @State private var step = PermissionGuideStep.introduction
    @State private var applicationResult: PermissionGuideResult?
    @State private var isRequesting = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("设置权限")
                    .font(.title2)
                    .bold()
                InfoButton(
                    title: "为什么需要权限",
                    details: [
                        "识别微信并创建分身",
                        "权限可随时在系统设置中更改"
                    ]
                )
                Spacer()
                Button("稍后处理", action: model.deferPermissionGuide)
                    .disabled(isRequesting)
            }
            .padding(DesignTokens.contentPadding)

            if step != .introduction {
                PermissionGuideProgressView(selectedStep: step)
                    .padding(.horizontal, DesignTokens.contentPadding)
                    .padding(.bottom, DesignTokens.roomySpacing)
            }

            Divider()

            Group {
                switch step {
                case .introduction:
                    PermissionGuideIntroductionView(
                        continueAction: showApplicationAccess
                    )
                case .applicationAccess:
                    PermissionGuideAccessView(
                        title: "允许访问微信",
                        systemImage: "app.badge.checkmark",
                        infoTitle: "用于创建分身",
                        infoDetails: [
                            "只读取微信应用信息",
                            "不会在这一步修改微信"
                        ],
                        result: applicationResult,
                        isRequesting: isRequesting,
                        backAction: showIntroduction,
                        nextAction: requestApplicationAccess
                    )
                case .appManagement:
                    PermissionGuideAppManagementView(
                        backAction: showApplicationAccess,
                        completeAction: model.completePermissionGuide
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 620, idealWidth: 680, minHeight: 460)
        .interactiveDismissDisabled()
    }

    private func requestApplicationAccess() {
        guard !isRequesting else { return }
        isRequesting = true
        Task {
            applicationResult = await model.requestWeChatApplicationAccess()
            isRequesting = false
            if applicationResult?.canContinue == true {
                showAppManagement()
            }
        }
    }

    private func showIntroduction() {
        step = .introduction
    }

    private func showApplicationAccess() {
        step = .applicationAccess
    }

    private func showAppManagement() {
        step = .appManagement
    }
}
