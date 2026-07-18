import SwiftUI

struct FileManagerIntroRow: View {
    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
                Text("按微信账号整理")
                    .font(.headline)
                Text("这里只展示文件类型和占用空间，不读取聊天内容。账号名称可以随时修改。")
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: "person.2.folder")
                .foregroundStyle(Color.accentColor)
        }
        .padding(.vertical, DesignTokens.compactSpacing)
    }
}
