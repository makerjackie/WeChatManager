import SwiftUI

struct InfoButton: View {
    let title: String
    let details: [String]
    @State private var showsDetails = false

    var body: some View {
        Button("查看详情", systemImage: "info.circle") {
            showsDetails.toggle()
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
        .help("查看详情")
        .popover(isPresented: $showsDetails, arrowEdge: .bottom) {
            VStack(alignment: .leading, spacing: DesignTokens.standardSpacing) {
                Text(title)
                    .font(.headline)

                ForEach(details.indices, id: \.self) { index in
                    Label(details[index], systemImage: "checkmark.circle")
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(DesignTokens.contentPadding)
            .frame(idealWidth: 320, maxWidth: 360, alignment: .leading)
        }
    }
}
