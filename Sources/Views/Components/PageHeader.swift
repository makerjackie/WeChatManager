import SwiftUI

struct PageHeader: View {
    let title: String
    let infoTitle: String
    let infoDetails: [String]

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: DesignTokens.standardSpacing) {
            Text(title)
                .font(.largeTitle)
                .bold()
            InfoButton(title: infoTitle, details: infoDetails)
            Spacer()
        }
    }
}
