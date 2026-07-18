import SwiftUI

struct StorageLocationRow: View {
    @Environment(AppModel.self) private var model
    let location: StorageLocation

    var body: some View {
        HStack(spacing: DesignTokens.standardSpacing) {
            Image(systemName: location.category.systemImage)
                .font(.title2)
                .foregroundStyle(location.isCache ? Color.orange : Color.accentColor)
                .frame(width: 32)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
                HStack {
                    Text(location.title)
                        .font(.headline)
                    Text(location.category.title)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                Text(location.detail)
                    .foregroundStyle(.secondary)
                Text(location.url.path)
                    .font(.callout.monospaced())
                    .foregroundStyle(.tertiary)
                    .lineLimit(2)
                    .textSelection(.enabled)
            }

            Spacer(minLength: DesignTokens.standardSpacing)

            if let size = location.allocatedSize {
                Text(size, format: .byteCount(style: .file))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }

            if location.isCache {
                Button(
                    model.selectedCacheIDs.contains(location.id) ? "取消选择缓存" : "选择缓存",
                    systemImage: model.selectedCacheIDs.contains(location.id) ? "checkmark.circle.fill" : "circle"
                ) {
                    model.toggleCacheSelection(location)
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
            }

            Menu("目录操作", systemImage: "ellipsis.circle") {
                Button("打开目录", systemImage: "folder", action: openLocation)
                Button("复制路径", systemImage: "document.on.document", action: copyPath)
            }
            .labelStyle(.iconOnly)
            .menuStyle(.borderlessButton)
        }
        .padding(.vertical, DesignTokens.compactSpacing)
    }

    private func openLocation() {
        model.open(location)
    }

    private func copyPath() {
        model.copyPath(of: location)
    }
}
