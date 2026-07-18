import SwiftUI

struct QuickActionsView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        HStack(spacing: DesignTokens.standardSpacing) {
            Button("启动微信", systemImage: "play.fill", action: model.launchOfficial)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(model.installation == nil)

            Button(
                model.isCreatingClone ? "正在创建分身" : "打开分身",
                systemImage: "plus.square.on.square",
                action: model.launchAdditionalInstance
            )
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(model.installation == nil || model.isCreatingClone)

            Button("退出全部", systemImage: "xmark.circle", action: model.terminateAllInstances)
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(model.runningInstanceCount == 0)

            Spacer()
        }
    }
}
