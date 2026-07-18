import SwiftUI

struct SaveClonePlanSheet: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var name = "常用方案"
    @State private var selectedCloneIDs: Set<String>
    let clones: [WeChatClone]

    init(clones: [WeChatClone]) {
        self.clones = clones
        _selectedCloneIDs = State(initialValue: Set(clones.map(\.id)))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.roomySpacing) {
            VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
                Text("保存当前方案")
                    .font(.title2)
                    .bold()
                Text("方案只记录如何重建分身，不备份聊天和登录数据。")
                    .foregroundStyle(.secondary)
            }

            TextField("方案名称", text: $name)
                .textFieldStyle(.roundedBorder)

            VStack(alignment: .leading, spacing: DesignTokens.standardSpacing) {
                Text("选择分身")
                    .font(.headline)
                ForEach(clones) { clone in
                    ClonePlanSelectionRow(
                        clone: clone,
                        isSelected: selectedCloneIDs.contains(clone.id)
                    ) {
                        toggleSelection(for: clone)
                    }
                }
            }

            HStack {
                Spacer()
                Button("取消", role: .cancel, action: dismiss.callAsFunction)
                Button("保存", action: save)
                    .buttonStyle(.borderedProminent)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(DesignTokens.contentPadding)
        .frame(minWidth: 460)
    }

    private func toggleSelection(for clone: WeChatClone) {
        if selectedCloneIDs.contains(clone.id) {
            selectedCloneIDs.remove(clone.id)
        } else {
            selectedCloneIDs.insert(clone.id)
        }
    }

    private func save() {
        if model.saveClonePlan(name: name, selectedCloneIDs: selectedCloneIDs) {
            dismiss()
        }
    }
}
