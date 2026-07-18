import Darwin
import Foundation

struct CommandTimeoutError: LocalizedError {
    let seconds: TimeInterval

    var errorDescription: String? {
        "命令在 \(seconds.formatted()) 秒内没有完成。"
    }
}

actor CommandRunner {
    func run(
        executableURL: URL,
        arguments: [String],
        timeout: TimeInterval? = nil
    ) throws -> CommandResult {
        let process = Process()
        let standardOutputPipe = Pipe()
        let standardErrorPipe = Pipe()
        process.executableURL = executableURL
        process.arguments = arguments
        process.standardOutput = standardOutputPipe
        process.standardError = standardErrorPipe

        if let timeout {
            let termination = DispatchSemaphore(value: 0)
            process.terminationHandler = { _ in termination.signal() }
            try process.run()

            if termination.wait(timeout: .now() + timeout) == .timedOut {
                process.terminate()
                if termination.wait(timeout: .now() + 1) == .timedOut {
                    Darwin.kill(process.processIdentifier, SIGKILL)
                    _ = termination.wait(timeout: .now() + 1)
                }
                throw CommandTimeoutError(seconds: timeout)
            }
        } else {
            try process.run()
            process.waitUntilExit()
        }

        let standardOutput = standardOutputPipe.fileHandleForReading.readDataToEndOfFile()
        let standardError = standardErrorPipe.fileHandleForReading.readDataToEndOfFile()
        return CommandResult(
            standardOutput: String(decoding: standardOutput, as: UTF8.self),
            standardError: String(decoding: standardError, as: UTF8.self),
            terminationStatus: process.terminationStatus
        )
    }
}
