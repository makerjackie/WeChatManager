import SwiftUI

struct StorageLocationRow: View {
    @Environment(AppModel.self) private var model
    @State private var showsPath = false
    let location: StorageLocation

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.compactSpacing) {
            HStack(spacing: DesignTokens.standardSpacing) {
                Image(systemName: location.category.systemImage)
                    .font(.title2)
                    .foregroundStyle(location.isCache ? Color.orange : Color.accentColor)
                    .frame(width: 28)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(location.title)
                        .font(.headline)
                    Text(location.detail)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: DesignTokens.standardSpacing)

                if let size = location.allocatedSize {
                    Text(size, format: .byteCount(style: .file))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }

                if location.isCache {
                    Button(
                        model.selectedCacheIDs.contains(location.id) ? "取消清理" : "选择清理",
                        systemImage: model.selectedCacheIDs.contains(location.id)
                            ? "checkmark.circle.fill"
                            : "circle",
                        action: toggleCacheSelection
                    )
                    .accessibilityLabel(
                        model.selectedCacheIDs.contains(location.id) ? "取消清理" : "选择清理"
                    )
                }

                Button("打开文件所在位置", systemImage: "folder", action: openLocation)
                    .accessibilityLabel("打开文件所在位置")
                Button("复制路径", systemImage: "document.on.document", action: copyPath)
                    .accessibilityLabel("复制路径")
            }
            .buttonStyle(.borderless)

            DisclosureGroup("文件地址", isExpanded: $showsPath) {
                Text(location.url.path)
                    .font(.callout.monospaced())
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                    .padding(.leading, 40)
            }
            .font(.callout)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, DesignTokens.compactSpacing)
    }

    private func openLocation() {
        model.open(location)
    }

    private func copyPath() {
        model.copyPath(of: location)
    }

    private func toggleCacheSelection() {
        model.toggleCacheSelection(location)
    }
}
