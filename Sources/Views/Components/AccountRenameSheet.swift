import SwiftUI

struct AccountRenameSheet: View {
    @Environment(\.dismiss) private var dismiss
    let group: StorageAccountGroup
    let onSave: (String) -> Void
    let onReset: () -> Void
    @State private var name: String

    init(
        group: StorageAccountGroup,
        onSave: @escaping (String) -> Void,
        onReset: @escaping () -> Void
    ) {
        self.group = group
        self.onSave = onSave
        self.onReset = onReset
        _name = State(initialValue: group.displayName)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.roomySpacing) {
            HStack(alignment: .firstTextBaseline) {
                Text("给微信账号命名")
                    .font(.title2)
                    .bold()
                InfoButton(
                    title: "名称说明",
                    details: ["只保存在这台 Mac", "不会修改微信资料"]
                )
                Spacer()
            }

            TextField("例如：工作微信", text: $name)
                .textFieldStyle(.roundedBorder)
                .onSubmit(save)

            HStack {
                Button("恢复“\(group.defaultName)”", action: reset)
                Spacer()
                Button("取消", role: .cancel, action: dismiss.callAsFunction)
                Button("保存", action: save)
                    .buttonStyle(.borderedProminent)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(DesignTokens.contentPadding)
        .frame(minWidth: 420)
    }

    private func save() {
        onSave(name)
        dismiss()
    }

    private func reset() {
        onReset()
        dismiss()
    }
}
