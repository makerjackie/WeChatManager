import SwiftUI

struct CompatibilityCard: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.standardSpacing) {
            Image(systemName: compatibilityIcon)
                .font(.title)
                .foregroundStyle(compatibilityColor)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
                Text(statusTitle)
                    .font(.headline)
            }
            Spacer()
            InfoButton(title: "兼容性详情", details: compatibilityDetails)
            Button("重新检查", systemImage: "arrow.clockwise", action: model.refresh)
        }
        .appCard()
    }

    private var statusTitle: String {
        switch model.compatibility {
        case .checking: "正在检查…"
        case .unavailable: "当前不可用"
        case .compatible: "当前版本可以使用"
        }
    }

    private var compatibilityDetails: [String] {
        var details = [model.compatibility.summary, "安装前会自动备份微信"]
        if let installation = model.installation {
            details.insert("微信版本：\(installation.version)", at: 0)
        }
        return details
    }

    private var compatibilityIcon: String {
        switch model.compatibility {
        case .checking: "hourglass"
        case .unavailable: "exclamationmark.triangle.fill"
        case .compatible: "checkmark.seal.fill"
        }
    }

    private var compatibilityColor: Color {
        switch model.compatibility {
        case .checking: .secondary
        case .unavailable: .orange
        case .compatible: .green
        }
    }
}
