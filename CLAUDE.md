# Snitch

Debugging tool for iOS: network requests and analytics events, each on its own screen in one SwiftUI inspector.

## Rules

- Personal open source project. Build everything from scratch. Never copy or adapt code, names, designs, or architecture from any employer's codebase.
- iOS only: no macOS or other platforms, so no `#if os(...)` guards. SwiftUI only for UI. iOS 16+, Swift 5.9+.
- The core target has zero third-party dependencies and never imports an analytics SDK. Each adapter is a separate SPM product. It depends on its SDK only when its hook needs the SDK's API (PostHog's `beforeSend`); otherwise it finds the SDK at runtime (AppsFlyer), so apps download nothing extra.
- Debug-only by default. Guard public entry points with `#if DEBUG` or a clear runtime opt-in so it can't ship active in a release build by accident.
- No telemetry, no network calls of its own, no data leaves the device.
- Never print request bodies, tokens, or headers to the console or logs.
- Keep code minimal and clean. Prefer small types and plain functions over layers of abstraction.
- Keep the public API small and document every public symbol.

## Workflow

- Work in small tasks, one feature at a time.
- Run the tests on the simulator after each change: `xcodebuild test -scheme Snitch-Package -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath .build/xcode -quiet`.
- Add a test for every new behavior.

## Versions

Each major version adds one logger, so apps can stay on the one that matches their SDKs.

- 1.x (shipped): network inspector. URLProtocol capture, list and detail, search and filters, cURL export, pause, floating button and shake to open.
- 2.x (shipped): PostHog adapter, a screen per SDK with a switcher and swipe, events linked to the uploads that sent them.
- 3.x (shipped): AppsFlyer adapter, found at runtime instead of as a dependency.
- Next: HAR export, header and body redaction.
