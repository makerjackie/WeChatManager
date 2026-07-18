import SwiftUI

struct FileManagerView: View {
    @Environment(AppModel.self) private var model
    @State private var editingAccount: StorageAccountGroup?

    var body: some View {
        @Bindable var model = model
        VStack(spacing: 0) {
            if !model.hasVisibleStorageLocations {
                if model.storageSearchText.isEmpty {
                    ContentUnavailableView(
                        "暂未找到微信文件",
                        systemImage: "folder.badge.questionmark",
                        description: Text("登录微信并收发文件后，再回来刷新。")
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ContentUnavailableView.search(text: model.storageSearchText)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                List {
                    FileManagerIntroRow()

                    ForEach(model.visibleStorageAccountGroups) { group in
                        AccountStorageSection(group: group) {
                            editingAccount = group
                        }
                    }

                    if !model.visibleAdditionalStorageLocations.isEmpty {
                        AdditionalStorageSection(
                            locations: model.visibleAdditionalStorageLocations
                        )
                    }
                }
                .scrollContentBackground(.visible)
            }

            CacheCleanupBar()
        }
        .navigationTitle("文件管理")
        .searchable(text: $model.storageSearchText, prompt: "搜索微信文件")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                if model.isCalculatingSizes {
                    Button("停止计算", systemImage: "stop.circle", action: model.cancelStorageScan)
                } else {
                    Button("计算空间", systemImage: "chart.pie", action: model.calculateStorageSizes)
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
        }
        .sheet(item: $editingAccount) { group in
            AccountRenameSheet(
                group: group,
                onSave: { name in
                    model.renameAccount(identifier: group.id, name: name)
                },
                onReset: {
                    model.resetAccountName(identifier: group.id)
                }
            )
        }
    }
}
