import SwiftUI

struct PlansView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.roomySpacing) {
                VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
                    Text("方案与更新")
                        .font(.largeTitle)
                        .bold()
                    Text("官方微信更新后，一次同步全部分身；换 Mac 时可从 iCloud 恢复分身配置。")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                CloneUpdateCard()
                PlanSyncCard()

                if model.clonePlans.isEmpty {
                    ContentUnavailableView(
                        "还没有保存方案",
                        systemImage: "square.stack.3d.up.slash",
                        description: Text("先创建并登录常用分身，再保存当前方案。")
                    )
                    .appCard()
                } else {
                    VStack(spacing: DesignTokens.standardSpacing) {
                        ForEach(model.clonePlans) { plan in
                            ClonePlanRow(plan: plan)
                        }
                    }
                }
            }
            .padding(DesignTokens.contentPadding)
            .frame(maxWidth: 900, alignment: .leading)
        }
        .navigationTitle("方案与更新")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button("保存当前方案", systemImage: "square.and.arrow.down") {
                    model.showsSavePlanSheet = true
                }
                .disabled(model.clones.isEmpty || model.isRunningCloneOperation)
                Button("从 iCloud 刷新", systemImage: "icloud.and.arrow.down", action: model.refreshClonePlans)
                    .disabled(model.isRunningCloneOperation)
            }
        }
        .sheet(isPresented: $model.showsSavePlanSheet) {
            SaveClonePlanSheet(clones: model.clones)
                .environment(model)
        }
        .overlay {
            if model.isRunningCloneOperation {
                VStack(spacing: DesignTokens.standardSpacing) {
                    ProgressView(value: model.cloneOperationProgress)
                        .frame(maxWidth: 280)
                    Text(model.cloneOperationDescription)
                        .foregroundStyle(.secondary)
                }
                .padding(DesignTokens.roomySpacing)
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: DesignTokens.cardCornerRadius))
            }
        }
    }
}
