//
//  ClientThread.swift
//  Snitch
//
//  Created by BOniani on 09/11/2026.
//

import Foundation

struct ClientThread {
    private let runLoop: CFRunLoop
    private let modes: [CFString]

    static func current() -> ClientThread {
        let runLoop = CFRunLoopGetCurrent()!
        var modes = [CFRunLoopMode.defaultMode.rawValue]
        if let mode = CFRunLoopCopyCurrentMode(runLoop), mode != .defaultMode {
            modes.append(mode.rawValue)
        }
        return ClientThread(runLoop: runLoop, modes: modes)
    }

    func perform(_ block: @escaping () -> Void) {
        CFRunLoopPerformBlock(runLoop, modes as CFArray, block)
        CFRunLoopWakeUp(runLoop)
    }
}
