import Foundation

actor CommandRunner {
    func run(executableURL: URL, arguments: [String]) throws -> CommandResult {
        let process = Process()
        let standardOutputPipe = Pipe()
        let standardErrorPipe = Pipe()
        process.executableURL = executableURL
        process.arguments = arguments
        process.standardOutput = standardOutputPipe
        process.standardError = standardErrorPipe

        try process.run()
        process.waitUntilExit()

        let standardOutput = standardOutputPipe.fileHandleForReading.readDataToEndOfFile()
        let standardError = standardErrorPipe.fileHandleForReading.readDataToEndOfFile()
        return CommandResult(
            standardOutput: String(decoding: standardOutput, as: UTF8.self),
            standardError: String(decoding: standardError, as: UTF8.self),
            terminationStatus: process.terminationStatus
        )
    }
}
