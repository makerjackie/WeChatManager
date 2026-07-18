import SwiftUI

struct DestinationView: View {
    let page: NavigationPage

    var body: some View {
        switch page {
        case .overview:
            DashboardView()
        case .instances:
            InstancesView()
        case .files:
            FileManagerView()
        case .enhancements:
            EnhancementsView()
        case .settings:
            SettingsView()
        }
    }
}
