import SwiftUI

struct InstancesView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.roomySpacing) {
                VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
                    Text("分身管理")
                        .font(.largeTitle)
                        .bold()
                    Text("每个分身拥有独立的 Bundle ID 和微信数据容器，可分别登录不同账号。")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                if let installation = model.installation {
                    OfficialInstanceCard(installation: installation)
                }

                if model.clones.isEmpty {
                    ContentUnavailableView(
                        "还没有微信分身",
                        systemImage: "square.on.square.dashed",
                        description: Text("创建第一个分身后，即可同时登录另一个微信账号。")
                    )
                    .appCard()
                } else {
                    VStack(spacing: DesignTokens.standardSpacing) {
                        ForEach(model.clones) { clone in
                            ManagedCloneRow(clone: clone)
                        }
                    }
                }

                ClonePrivacyCard()
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
                ProgressView("正在复制并签名微信，请稍候…")
                    .padding(DesignTokens.roomySpacing)
                    .background(.regularMaterial)
                    .clipShape(.rect(cornerRadius: DesignTokens.cardCornerRadius))
            }
        }
    }
}
