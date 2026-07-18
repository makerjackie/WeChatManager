import SwiftUI

struct CacheCleanupBar: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: DesignTokens.standardSpacing) {
                if model.isCalculatingSizes {
                    ProgressView(value: model.sizeScanProgress)
                        .frame(maxWidth: 220)
                    Text("正在计算空间…")
                        .foregroundStyle(.secondary)
                } else {
                    Text("已选择 \(model.selectedCacheCount) 项")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("安全清理缓存", systemImage: "trash", action: model.requestCleanup)
                    .buttonStyle(.borderedProminent)
                    .disabled(model.selectedCacheCount == 0)
            }
            .padding()
            .background(.bar)
        }
    }
}
