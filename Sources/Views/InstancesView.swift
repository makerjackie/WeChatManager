import SwiftUI

struct InstancesView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.roomySpacing) {
                PageHeader(
                    title: "微信分身",
                    infoTitle: "关于微信分身",
                    infoDetails: [
                        "每个分身可登录一个微信账号",
                        "分身之间互不影响",
                        "更新或移除分身不会删除聊天数据"
                    ]
                )

                if let installation = model.installation {
                    OfficialInstanceCard(installation: installation)
                }

                if model.clones.isEmpty {
                    ContentUnavailableView(
                        "还没有微信分身",
                        systemImage: "square.on.square.dashed",
                        description: Text("创建分身，登录另一个账号。")
                    )
                    .appCard()
                } else {
                    VStack(spacing: DesignTokens.standardSpacing) {
                        ForEach(model.clones) { clone in
                            ManagedCloneRow(clone: clone)
                        }
                    }
                }
            }
            .padding(DesignTokens.contentPadding)
            .frame(maxWidth: 860, alignment: .leading)
        }
        .navigationTitle("分身管理")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button("方案与更新", systemImage: "arrow.triangle.2.circlepath.icloud") {
                    model.selectedPage = .plans
                }
                Button("创建分身", systemImage: "plus", action: model.createClone)
                    .disabled(model.installation == nil || model.isCreatingClone)
                Button("刷新", systemImage: "arrow.clockwise", action: model.refresh)
            }
        }
        .overlay {
            if model.isCreatingClone {
                ProgressView("正在创建分身…")
                    .padding(DesignTokens.roomySpacing)
                    .background(.regularMaterial)
                    .clipShape(.rect(cornerRadius: DesignTokens.cardCornerRadius))
            }
        }
    }
}
