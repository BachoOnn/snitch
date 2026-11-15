//
//  EventRecordingTests.swift
//  SnitchTests
//
//  Created by BOniani on 15/11/2026.
//

import Foundation
import Testing
@testable import Snitch

extension CaptureTests {
    @Suite(.serialized)
    final class EventRecording {
        private let source = "Recording\(UUID().uuidString)"

        init() {
            Snitch.start(showsButton: false, opensOnShake: false)
        }

        deinit {
            Snitch.events.clear(source: source)
            Snitch.stop()
        }

        private var recorded: [String] {
            Snitch.events.events.filter { $0.source == source }.map(\.name)
        }

        @Test func recordsWhileRunning() {
            Snitch.record(AnalyticsEvent(source: source, name: "first"))
            #expect(recorded == ["first"])
            #expect(Snitch.events.sources.contains(source))
        }

        @Test func recognizesSnitchsOwnScreens() {
            #expect(Snitch.isOwnScreen("FloatingDot"))
            #expect(Snitch.isOwnScreen("UIHostingController<FloatingDot>"))
            #expect(!Snitch.isOwnScreen("ProductDetail"))
            Snitch.setInspectorVisible(true)
            #expect(Snitch.isOwnScreen("ProductDetail"), "everything on screen while the inspector is open is Snitch's")
            Snitch.setInspectorVisible(false)
            #expect(!Snitch.isOwnScreen("ProductDetail"))
        }

        @Test func skipsWhilePausedOrStopped() {
            Snitch.pause()
            Snitch.record(AnalyticsEvent(source: source, name: "paused"))
            Snitch.resume()
            Snitch.stop()
            Snitch.record(AnalyticsEvent(source: source, name: "stopped"))
            #expect(recorded.isEmpty)
        }
    }
}
