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
                Text("\(plan.items.count) 个分身 · 保存自微信 \(plan.sourceVersion)")
                    .foregroundStyle(.secondary)
                Text(plan.modifiedAt, format: .dateTime.year().month().day().hour().minute())
                    .foregroundStyle(.tertiary)
            }

            Spacer()

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
            } message: {
                Text("将创建缺少的分身并更新版本或名称不同的分身；不会删除方案外的分身。")
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
            } message: {
                Text("只删除方案记录，不会删除任何微信分身或账号数据。")
            }
        }
        .appCard()
    }
}
