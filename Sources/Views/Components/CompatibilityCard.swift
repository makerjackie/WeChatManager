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
                Text("版本兼容性")
                    .font(.headline)
                Text(model.compatibility.summary)
                if let installation = model.installation {
                    Text("微信 \(installation.version)")
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button("重新检查", systemImage: "arrow.clockwise", action: model.refresh)
        }
        .appCard()
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
