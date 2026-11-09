// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Snitch",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Snitch", targets: ["Snitch"]),
    ],
    targets: [
        .target(name: "Snitch", resources: [.process("Resources")]),
        .testTarget(name: "SnitchTests", dependencies: ["Snitch"]),
    ]
)
