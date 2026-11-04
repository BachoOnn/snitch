// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Tapwire",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "Tapwire", targets: ["Tapwire"]),
    ],
    targets: [
        .target(name: "Tapwire"),
        .testTarget(name: "TapwireTests", dependencies: ["Tapwire"]),
    ]
)
