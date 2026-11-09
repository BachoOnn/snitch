# Snitch

Debugging tool for iOS: network requests and analytics events in one SwiftUI timeline.

## Rules

- Personal open source project. Build everything from scratch. Never copy or adapt code, names, designs, or architecture from any employer's codebase.
- iOS only: no macOS or other platforms, so no `#if os(...)` guards. SwiftUI only for UI. iOS 16+, Swift 5.9+.
- The core target has zero third-party dependencies. Analytics adapters (PostHog, AppsFlyer) are separate SPM products that depend on their SDKs. Core defines a small protocol and never imports them.
- Debug-only by default. Guard public entry points with `#if DEBUG` or a clear runtime opt-in so it can't ship active in a release build by accident.
- No telemetry, no network calls of its own, no data leaves the device.
- Never print request bodies, tokens, or headers to the console or logs.
- Keep code minimal and clean. Prefer small types and plain functions over layers of abstraction.
- Keep the public API small and document every public symbol.

## Workflow

- Work in small tasks, one feature at a time.
- Run the tests on the simulator after each change: `xcodebuild test -scheme Snitch -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath .build/xcode -quiet`.
- Add a test for every new behavior.

## Roadmap

- v1: URLProtocol capture, SwiftUI list and detail, search and filters, cURL export, shake trigger.
- v1.1: PostHog and AppsFlyer adapters, unified timeline with source filter.
- v1.2: HAR export, redaction, labeling of batched analytics requests.
