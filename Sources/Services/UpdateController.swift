import Foundation
import Observation
import Sparkle

@MainActor
@Observable
final class UpdateController {
    @ObservationIgnored
    private let controller: SPUStandardUpdaterController

    init() {
        controller = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }

    var canCheckForUpdates: Bool {
        controller.updater.canCheckForUpdates
    }

    var automaticallyChecksForUpdates: Bool {
        controller.updater.automaticallyChecksForUpdates
    }

    var automaticallyDownloadsUpdates: Bool {
        controller.updater.automaticallyDownloadsUpdates
    }

    func checkForUpdates() {
        controller.checkForUpdates(nil)
    }
}
