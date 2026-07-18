import SwiftUI

struct AdditionalStorageSection: View {
    let locations: [StorageLocation]
    @State private var isExpanded = false

    var body: some View {
        Section("其他") {
            DisclosureGroup("其他数据位置", isExpanded: $isExpanded) {
                ForEach(locations) { location in
                    StorageLocationRow(location: location)
                        .listRowSeparator(.hidden)
                }
            }
        }
    }
}
