import SwiftUI

struct EnhancementSafetyCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.standardSpacing) {
            Label("安全边界", systemImage: "lock.shield")
                .font(.headline)
            Text("增强配置来自开源项目 WeChatTweak。应用会校验微信构建号、限制可修改的功能、先保存完整备份，并在写入后验证代码签名。任何一步不匹配都会停止。")
                .foregroundStyle(.secondary)
            Text("增强功能可能受微信服务条款或版本更新影响，请自行判断是否启用。文件管理和普通多开不需要修改微信。")
                .foregroundStyle(.secondary)
        }
        .appCard()
    }
}
