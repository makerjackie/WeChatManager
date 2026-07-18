import SwiftUI

struct DashboardFileSummaryView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.standardSpacing) {
            HStack {
                Label("常用文件入口", systemImage: "folder.fill")
                    .font(.headline)
                Spacer()
                Button("查看全部") {
                    model.selectedPage = .files
                }
            }

            let shortcuts = model.storageLocations.filter {
                $0.category == .files || $0.category == .videos || $0.category == .root
            }
            if shortcuts.isEmpty {
                ContentUnavailableView(
                    "还没有找到微信文件",
                    systemImage: "folder.badge.questionmark",
                    description: Text("登录微信后再刷新即可自动定位。")
                )
            } else {
                ForEach(shortcuts.prefix(4)) { location in
                    Button {
                        model.open(location)
                    } label: {
                        HStack {
                            Label(location.title, systemImage: location.category.systemImage)
                            Spacer()
                            Image(systemName: "arrow.up.forward.app")
                                .accessibilityHidden(true)
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .appCard()
    }
}
