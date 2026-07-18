import Foundation

enum ShellEscaping {
    static func quote(_ value: String) -> String {
        "'" + value.replacing("'", with: "'\\''") + "'"
    }

    static func appleScriptString(_ value: String) -> String {
        "\"" + value
            .replacing("\\", with: "\\\\")
            .replacing("\"", with: "\\\"") + "\""
    }
}
