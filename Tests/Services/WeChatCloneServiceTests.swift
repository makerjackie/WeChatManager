import XCTest
@testable import WeChatManager

final class WeChatCloneServiceTests: XCTestCase {
    func testDiscoversOnlyMarkedManagedClones() async throws {
        let home = FileManager.default.temporaryDirectory.appending(
            path: "WeChatCloneServiceTests-\(UUID().uuidString)"
        )
        defer { try? FileManager.default.removeItem(at: home) }
        let applications = home.appending(path: "Applications")
        try FileManager.default.createDirectory(at: applications, withIntermediateDirectories: true)
        try writeApplication(
            at: applications.appending(path: "微信分身 1.app"),
            plist: [
                "CFBundleIdentifier": "com.makerjackie.WeChatManager.clone.1",
                "CFBundleDisplayName": "微信分身 1",
                "WeChatManagerClone": true,
                "WeChatManagerCloneIndex": 1,
                "WeChatManagerSourceVersion": "4.1.11",
                "WeChatManagerSourceBuild": "269110"
            ]
        )
        try writeApplication(
            at: applications.appending(path: "其他应用.app"),
            plist: [
                "CFBundleIdentifier": "example.other",
                "CFBundleDisplayName": "其他应用"
            ]
        )

        let clones = await WeChatCloneService(homeDirectory: home).clones()

        XCTAssertEqual(clones.count, 1)
        XCTAssertEqual(clones[0].index, 1)
        XCTAssertEqual(clones[0].sourceBuild, "269110")
    }

    func testCreatesAndSignsCloneFromOfficialInstallation() async throws {
        let root = FileManager.default.temporaryDirectory.appending(
            path: "WeChatCloneCreationTests-\(UUID().uuidString)"
        )
        defer { try? FileManager.default.removeItem(at: root) }
        let home = root.appending(path: "home")
        let source = root.appending(path: "WeChat.app")
        try FileManager.default.createDirectory(at: home, withIntermediateDirectories: true)
        try writeRunnableApplication(at: source)
        let installation = WeChatInstallation(
            applicationURL: source,
            version: "4.1.11",
            build: "269110",
            teamIdentifier: AppConstants.officialWeChatTeamIdentifier
        )
        let service = WeChatCloneService(
            homeDirectory: home,
            managedApplicationsDirectory: home.appending(path: "Applications")
        )

        let clone = try await service.createNext(from: installation)
        let discovered = await service.clones()

        XCTAssertEqual(clone.bundleIdentifier, "com.makerjackie.WeChatManager.clone.1")
        XCTAssertTrue(FileManager.default.fileExists(atPath: clone.applicationURL.path))
        XCTAssertEqual(discovered.count, 1)
        XCTAssertEqual(discovered[0].bundleIdentifier, clone.bundleIdentifier)
        XCTAssertEqual(
            discovered[0].applicationURL.resolvingSymlinksInPath(),
            clone.applicationURL.resolvingSymlinksInPath()
        )
        let plistData = try Data(
            contentsOf: clone.applicationURL.appending(path: "Contents/Info.plist")
        )
        let plist = try PropertyListSerialization.propertyList(
            from: plistData,
            options: [],
            format: nil
        ) as? [String: Any]
        XCTAssertNil(plist?["CFBundleURLTypes"])
    }

    func testUpdatingLegacyCloneMovesItIntoManagedApplicationsDirectory() async throws {
        let root = FileManager.default.temporaryDirectory.appending(
            path: "WeChatCloneMigrationTests-\(UUID().uuidString)"
        )
        defer { try? FileManager.default.removeItem(at: root) }
        let home = root.appending(path: "home")
        let legacyApplications = home.appending(path: "Applications")
        let managedApplications = root.appending(path: "Applications")
        let trash = root.appending(path: "Trash")
        let source = root.appending(path: "WeChat.app")
        try FileManager.default.createDirectory(at: home, withIntermediateDirectories: true)
        try writeRunnableApplication(at: source)
        let installation = WeChatInstallation(
            applicationURL: source,
            version: "4.1.11",
            build: "269110",
            teamIdentifier: AppConstants.officialWeChatTeamIdentifier
        )
        let legacyService = WeChatCloneService(
            homeDirectory: home,
            managedApplicationsDirectory: legacyApplications,
            trashDirectory: trash
        )
        let legacyClone = try await legacyService.createNext(from: installation)
        let migrationService = WeChatCloneService(
            homeDirectory: home,
            managedApplicationsDirectory: managedApplications,
            trashDirectory: trash
        )

        let migratedClone = try await migrationService.update(legacyClone, from: installation)

        XCTAssertEqual(
            migratedClone.applicationURL.deletingLastPathComponent().standardizedFileURL,
            managedApplications.standardizedFileURL
        )
        XCTAssertFalse(FileManager.default.fileExists(atPath: legacyClone.applicationURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: migratedClone.applicationURL.path))
        XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: trash.path).count, 1)
    }

    func testCreatesExactPlanIndexAndPreservesDisplayNameWhenUpdating() async throws {
        let root = FileManager.default.temporaryDirectory.appending(
            path: "WeChatClonePlanRestoreTests-\(UUID().uuidString)"
        )
        defer { try? FileManager.default.removeItem(at: root) }
        let home = root.appending(path: "home")
        let applications = root.appending(path: "Applications")
        let trash = root.appending(path: "Trash")
        let source = root.appending(path: "WeChat.app")
        try FileManager.default.createDirectory(at: home, withIntermediateDirectories: true)
        try writeRunnableApplication(at: source)
        let installation = WeChatInstallation(
            applicationURL: source,
            version: "4.1.11",
            build: "269110",
            teamIdentifier: AppConstants.officialWeChatTeamIdentifier
        )
        let service = WeChatCloneService(
            homeDirectory: home,
            managedApplicationsDirectory: applications,
            trashDirectory: trash
        )

        let created = try await service.create(
            index: 3,
            displayName: "工作微信",
            from: installation
        )
        let updated = try await service.update(created, from: installation)

        XCTAssertEqual(created.index, 3)
        XCTAssertEqual(created.displayName, "工作微信")
        XCTAssertEqual(updated.displayName, "工作微信")
        XCTAssertEqual(updated.bundleIdentifier, "com.makerjackie.WeChatManager.clone.3")
    }

    private func writeApplication(at applicationURL: URL, plist: [String: Any]) throws {
        let contents = applicationURL.appending(path: "Contents")
        try FileManager.default.createDirectory(at: contents, withIntermediateDirectories: true)
        let data = try PropertyListSerialization.data(
            fromPropertyList: plist,
            format: .xml,
            options: 0
        )
        try data.write(to: contents.appending(path: "Info.plist"))
    }

    private func writeRunnableApplication(at applicationURL: URL) throws {
        let executableDirectory = applicationURL.appending(path: "Contents/MacOS")
        try FileManager.default.createDirectory(
            at: executableDirectory,
            withIntermediateDirectories: true
        )
        try writeApplication(
            at: applicationURL,
            plist: [
                "CFBundleIdentifier": AppConstants.weChatBundleIdentifier,
                "CFBundleDisplayName": "WeChat",
                "CFBundleExecutable": "WeChat",
                "CFBundlePackageType": "APPL",
                "CFBundleShortVersionString": "4.1.11",
                "CFBundleVersion": "269110",
                "CFBundleURLTypes": [["CFBundleURLSchemes": ["wechat"]]]
            ]
        )
        let executable = executableDirectory.appending(path: "WeChat")
        try Data("#!/bin/sh\nexit 0\n".utf8).write(to: executable)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o755],
            ofItemAtPath: executable.path
        )
    }
}
