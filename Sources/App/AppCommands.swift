import SwiftUI

struct AppCommands: Commands {
    let updateController: UpdateController

    var body: some Commands {
        CommandGroup(after: .appInfo) {
            Button("检查更新…", action: updateController.checkForUpdates)
                .disabled(!updateController.canCheckForUpdates)
        }
    }
}
