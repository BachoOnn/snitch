# Tapwire

See what your iOS app sends and logs: network requests and analytics events, side by side, in one timeline.

> **Status:** early development. The API below is the target design and will change.

## What it is

Tapwire is an in-app debugging tool for iOS. It records your app's own `URLSession` traffic and, with optional adapters, the analytics events your app emits (PostHog, AppsFlyer). Both show up in a single SwiftUI inspector.

## What it is not

- **Not a proxy.** Tapwire does not intercept or decrypt traffic on the network and does not break TLS. It observes requests made by your own app, from inside your app.
- **Not for production.** It is built for debug builds and is designed to be easy to exclude from release builds.
- **No telemetry.** Nothing leaves the device. Tapwire does not phone home.

## Planned features

**v1: network inspector**
- Request and response capture via `URLProtocol`
- SwiftUI list and detail views with search and filters
- cURL export and a shake or gesture trigger

**v1.1: analytics timeline**
- Optional adapters as separate products: `TapwirePostHog`, `TapwireAppsFlyer`
- Network calls and analytics events in one timeline, filterable by source

**v1.2**
- HAR export
- Header and body redaction
- Labeling of batched analytics requests

## Installation

Swift Package Manager:

```swift
.package(url: "https://github.com/<your-username>/tapwire", from: "0.1.0")
```

## Quick start (target API)

```swift
#if DEBUG
import Tapwire

Tapwire.start()
#endif
```

## Requirements

iOS 16+, Swift 5.9+

Running the tests requires Xcode 16+ (Swift 6 toolchain) for Swift Testing.

## Security

See [SECURITY.md](SECURITY.md).

## License

Apache 2.0. See [LICENSE](LICENSE).
