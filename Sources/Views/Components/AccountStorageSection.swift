import SwiftUI

struct AccountStorageSection: View {
    let group: StorageAccountGroup
    let renameAction: () -> Void
    @State private var showsAccountData = false

    var body: some View {
        Section {
            ForEach(group.primaryLocations) { location in
                StorageLocationRow(location: location)
                    .listRowSeparator(.hidden)
            }

            if !group.additionalLocations.isEmpty {
                DisclosureGroup("更多账号数据", isExpanded: $showsAccountData) {
                    ForEach(group.additionalLocations) { location in
                        StorageLocationRow(location: location)
                            .listRowSeparator(.hidden)
                    }
                }
            }
        } header: {
            HStack {
                Label(group.displayName, systemImage: "person.crop.circle")
                    .font(.headline)
                Spacer()
                Button("重命名", systemImage: "pencil", action: renameAction)
                    .buttonStyle(.borderless)
            }
            .textCase(nil)
        }
    }
}
