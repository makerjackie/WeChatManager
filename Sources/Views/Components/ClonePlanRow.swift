import SwiftUI

struct ClonePlanRow: View {
    @Environment(AppModel.self) private var model
    @State private var showsApplyConfirmation = false
    @State private var showsDeleteConfirmation = false
    let plan: ClonePlan

    var body: some View {
        HStack(spacing: DesignTokens.standardSpacing) {
            Image(systemName: "square.stack.3d.up.fill")
                .font(.title)
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
                Text(plan.name)
                    .font(.headline)
                Text("\(plan.items.count) 个分身")
                    .foregroundStyle(.secondary)
            }

            Spacer()

            InfoButton(
                title: plan.name,
                details: [
                    "保存自微信 \(plan.sourceVersion)",
                    "保存时间：\(plan.modifiedAt.formatted(date: .abbreviated, time: .shortened))",
                    "只保存分身数量和名称"
                ]
            )

            Button("应用方案", systemImage: "arrow.down.to.line") {
                showsApplyConfirmation = true
            }
            .buttonStyle(.borderedProminent)
            .disabled(model.installation == nil || model.isRunningCloneOperation)
            .confirmationDialog(
                "应用“\(plan.name)”？",
                isPresented: $showsApplyConfirmation,
                titleVisibility: .visible
            ) {
                Button("开始应用") {
                    model.applyClonePlan(plan)
                }
                Button("取消", role: .cancel) { }
            }

            Button("删除方案", systemImage: "trash", role: .destructive) {
                showsDeleteConfirmation = true
            }
            .labelStyle(.iconOnly)
            .confirmationDialog(
                "删除“\(plan.name)”？",
                isPresented: $showsDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("删除方案", role: .destructive) {
                    model.deleteClonePlan(plan)
                }
                Button("取消", role: .cancel) { }
            }
        }
        .appCard()
    }
}
