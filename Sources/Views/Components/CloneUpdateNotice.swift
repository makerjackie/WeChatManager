import SwiftUI

struct CloneUpdateNotice: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        if !model.outdatedClones.isEmpty {
            HStack(spacing: DesignTokens.standardSpacing) {
                Label("检测到 \(model.outdatedClones.count) 个分身需要更新", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Spacer()
                Button("前往一键更新", systemImage: "arrow.right") {
                    model.selectedPage = .plans
                }
            }
            .appCard()
        }
    }
}
