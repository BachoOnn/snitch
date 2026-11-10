# Snitch

See what your iOS app sends and logs: network requests and analytics events, side by side, in one timeline.

> **Status:** early development. The network inspector (v1) works; the API may still change before 1.0.

## What it is

Snitch is an in-app debugging tool for iOS. It records your app's own `URLSession` traffic and, with optional adapters, the analytics events your app emits (PostHog, AppsFlyer). Both show up in a single SwiftUI inspector.

## What it is not

- **Not a proxy.** Snitch does not intercept or decrypt traffic on the network and does not break TLS. It observes requests made by your own app, from inside your app.
- **Not for production.** It is built for debug builds and is designed to be easy to exclude from release builds.
- **No telemetry.** Nothing leaves the device. Snitch does not phone home.

## Features

**v1: network inspector**
- Request and response capture via `URLProtocol`, kept in memory only
- A timeline of every request, newest first, with search and filters for status, method and host
- Request and response detail with headers, pretty or raw JSON bodies and find-in-body
- Sensitive headers such as `Authorization` and `Cookie` hidden until you tap to reveal them
- Copy a one-line summary, a body, or the whole request as cURL
- Pause recording, with the paused gaps marked on the timeline
- A small floating button and shake-to-open, both optional
- Native Liquid Glass on iOS 26, with a material fallback on iOS 16 to 25

## Planned

**v1.1: analytics timeline**
- Optional adapters as separate products: `SnitchPostHog`, `SnitchAppsFlyer`
- Network calls and analytics events in one timeline, filterable by source

**v1.2**
- HAR export
- Header and body redaction
- Labeling of batched analytics requests

## Installation

Swift Package Manager:

```swift
.package(url: "https://github.com/BachoOnn/snitch", from: "1.0.0")
```

## Quick start

Start Snitch as early as possible, for example in your app's `init`:

```swift
import Snitch

@main
struct MyApp: App {
    init() {
        Snitch.start()
    }
    // ...
}
```

Tap the floating button or shake the device to open the inspector. In builds without
`DEBUG`, every Snitch call does nothing.

`Snitch.start()` covers `URLSession.shared`. For your own sessions, add Snitch to the
configuration before creating the session:

```swift
let configuration = URLSessionConfiguration.default
Snitch.install(in: configuration)
let session = URLSession(configuration: configuration)
```

Other options:

```swift
Snitch.start(showsButton: false, opensOnShake: true) // choose how the inspector opens
Snitch.present()                                       // open it from your own debug menu
Snitch.pause()                                         // stop recording until resume()
Snitch.resume()
```

## Requirements

iOS 16+, Swift 5.9+

Running the tests requires Xcode 16+ (Swift 6 toolchain) for Swift Testing.

## Security

See [SECURITY.md](SECURITY.md).

## License

Apache 2.0. See [LICENSE](LICENSE).
