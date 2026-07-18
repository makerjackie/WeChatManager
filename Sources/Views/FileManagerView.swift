import SwiftUI

struct FileManagerView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        VStack(spacing: 0) {
            if model.filteredStorageLocations.isEmpty {
                ContentUnavailableView.search(text: model.storageSearchText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(model.filteredStorageLocations) { location in
                    StorageLocationRow(location: location)
                }
                .scrollContentBackground(.visible)
            }

            CacheCleanupBar()
        }
        .navigationTitle("文件管理")
        .searchable(text: $model.storageSearchText, prompt: "搜索目录或路径")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                if model.isCalculatingSizes {
                    Button("停止计算", systemImage: "stop.circle", action: model.cancelStorageScan)
                } else {
                    Button("计算占用", systemImage: "chart.pie", action: model.calculateStorageSizes)
                }
                Button("刷新", systemImage: "arrow.clockwise", action: model.refresh)
            }
        }
        .confirmationDialog(
            "将所选缓存移入废纸篓？",
            isPresented: $model.showsCleanupConfirmation,
            titleVisibility: .visible
        ) {
            Button("移入废纸篓", role: .destructive, action: model.cleanSelectedCaches)
            Button("取消", role: .cancel) { }
        } message: {
            Text("不会删除聊天记录、收到的文件或视频。关闭微信后执行，缓存仍可从废纸篓恢复。")
        }
    }
}
