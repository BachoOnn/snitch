import Foundation

/// The thread a `URLProtocol` started loading on. `URLProtocolClient` callbacks must
/// be delivered there, in the run loop modes it was running in.
struct ClientThread {
    private let runLoop: CFRunLoop
    private let modes: [CFString]

    /// Captures the calling thread's run loop and its current mode.
    static func current() -> ClientThread {
        let runLoop = CFRunLoopGetCurrent()!
        var modes = [CFRunLoopMode.defaultMode.rawValue]
        if let mode = CFRunLoopCopyCurrentMode(runLoop), mode != .defaultMode {
            modes.append(mode.rawValue)
        }
        return ClientThread(runLoop: runLoop, modes: modes)
    }

    /// Runs `block` on the captured thread.
    func perform(_ block: @escaping () -> Void) {
        CFRunLoopPerformBlock(runLoop, modes as CFArray, block)
        CFRunLoopWakeUp(runLoop)
    }
}
