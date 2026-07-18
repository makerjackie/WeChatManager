import SwiftUI

struct FileManagerIntroRow: View {
    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
                Text("按微信账号整理")
                    .font(.headline)
                Text("按账号整理，不读取聊天内容。")
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: "person.2.folder")
                .foregroundStyle(Color.accentColor)
        }
        .padding(.vertical, DesignTokens.compactSpacing)
    }
}
