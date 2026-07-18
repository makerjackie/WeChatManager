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
                if case let .unavailable(reason, _) = model.compatibility {
                    Text(reason)
                        .foregroundStyle(.secondary)
                }
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
        case .unavailable:
            if let installation = model.installation {
                "微信 \(installation.version) 暂不支持"
            } else {
                "尚未找到微信"
            }
        case .compatible: "当前版本可以使用"
        }
    }

    private var compatibilityDetails: [String] {
        var details = [model.compatibility.summary]
        if let installation = model.installation {
            details.insert("微信版本：\(installation.version)", at: 0)
            details.insert("内部构建：\(installation.build)", at: 1)
        }
        if !model.compatibility.supportedBuilds.isEmpty {
            details.append(contentsOf: model.compatibility.supportedBuilds.map {
                "可用：\(CompatibleWeChatRelease.label(for: $0))"
            })
        }
        if case .compatible = model.compatibility {
            details.append("安装前会自动备份微信")
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
