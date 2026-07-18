import SwiftUI

struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            DestinationView(page: model.selectedPage ?? .overview)
        }
        .task(model.start)
        .alert(item: alertBinding) { message in
            Alert(
                title: Text(message.title),
                message: Text(message.detail)
            )
        }
    }

    private var alertBinding: Binding<UserMessage?> {
        @Bindable var model = model
        return $model.message
    }
}

#Preview {
    RootView()
        .environment(AppModel())
        .frame(width: 1080, height: 720)
}
