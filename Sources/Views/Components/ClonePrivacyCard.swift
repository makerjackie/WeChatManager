import SwiftUI

struct ClonePrivacyCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.standardSpacing) {
            Label("独立且可维护", systemImage: "person.2.badge.gearshape")
                .font(.headline)
            Text("分身安装在系统“应用程序”文件夹，不修改官方微信，也不依赖特定微信构建号。微信更新后，可用“更新分身”替换应用代码，原有分身账号容器会保留。")
                .foregroundStyle(.secondary)
            Text("系统会把每个分身视作独立应用，摄像头、麦克风、通知等权限可能需要分别确认。")
                .foregroundStyle(.secondary)
        }
        .appCard()
    }
}
