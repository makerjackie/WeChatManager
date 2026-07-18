import Foundation

struct WeChatClonePlistEditor {
    func editedPlist(
        _ plist: [String: Any],
        index: Int,
        displayName: String,
        version: String,
        build: String
    ) -> [String: Any] {
        var edited = plist
        edited["CFBundleIdentifier"] = bundleIdentifier(for: index)
        edited["CFBundleName"] = displayName
        edited["CFBundleDisplayName"] = displayName
        edited["CFBundleGetInfoString"] = displayName
        edited["WeChatManagerClone"] = true
        edited["WeChatManagerCloneIndex"] = index
        edited["WeChatManagerSourceVersion"] = version
        edited["WeChatManagerSourceBuild"] = build
        edited.removeValue(forKey: "CFBundleURLTypes")
        return edited
    }

    func bundleIdentifier(for index: Int) -> String {
        "com.makerjackie.WeChatManager.clone.\(index)"
    }
}
