// swift-tools-version: 5.9
//
//  Package.swift
//  Snitch
//
//  Created by BOniani on 04/11/2026.
//

import PackageDescription

let package = Package(
    name: "Snitch",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Snitch", targets: ["Snitch"]),
        .library(name: "SnitchPostHog", targets: ["SnitchPostHog"]),
    ],
    dependencies: [
        .package(url: "https://github.com/PostHog/posthog-ios.git", from: "3.28.0"),
    ],
    targets: [
        .target(name: "Snitch", resources: [.process("Resources")]),
        .target(
            name: "SnitchPostHog",
            dependencies: ["Snitch", .product(name: "PostHog", package: "posthog-ios")],
            resources: [.process("Resources")]
        ),
        .testTarget(name: "SnitchTests", dependencies: ["Snitch"]),
        .testTarget(name: "SnitchPostHogTests", dependencies: ["SnitchPostHog"]),
    ]
)
