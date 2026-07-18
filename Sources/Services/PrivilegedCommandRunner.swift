import Foundation

actor PrivilegedCommandRunner {
    func run(shellCommand: String) throws {
        let source = "do shell script \(ShellEscaping.appleScriptString(shellCommand)) with administrator privileges"
        guard let script = NSAppleScript(source: source) else {
            throw AppError(message: "无法创建系统授权请求。")
        }

        var error: NSDictionary?
        script.executeAndReturnError(&error)
        if let error {
            let message = error[NSAppleScript.errorMessage] as? String ?? "管理员授权失败"
            throw AppError(message: message)
        }
    }
}
