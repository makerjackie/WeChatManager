import SwiftUI

struct FileManagerIntroRow: View {
    var body: some View {
        HStack {
            Label("按微信账号整理", systemImage: "person.2.folder")
                .font(.headline)
                .foregroundStyle(Color.accentColor)
            Spacer()
            InfoButton(
                title: "文件管理说明",
                details: [
                    "按账号显示常用文件夹",
                    "不会读取或上传聊天内容",
                    "账号名称只保存在这台 Mac"
                ]
            )
        }
        .padding(.vertical, DesignTokens.compactSpacing)
    }
}
