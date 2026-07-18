import Foundation

struct WeChatClonePlistEditor {
    func editedPlist(
        _ plist: [String: Any],
        index: Int,
        version: String,
        build: String
    ) -> [String: Any] {
        var edited = plist
        let displayName = "微信分身 \(index)"
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
