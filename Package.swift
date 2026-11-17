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
        .library(name: "SnitchAppsFlyer", targets: ["SnitchAppsFlyer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/PostHog/posthog-ios.git", from: "3.28.0"),
        .package(url: "https://github.com/AppsFlyerSDK/AppsFlyerFramework.git", "6.1.0"..<"8.0.0"),
    ],
    targets: [
        .target(name: "Snitch", resources: [.process("Resources")]),
        .target(
            name: "SnitchPostHog",
            dependencies: ["Snitch", .product(name: "PostHog", package: "posthog-ios")],
            resources: [.process("Resources")]
        ),
        .target(
            name: "SnitchAppsFlyer",
            dependencies: ["Snitch", .product(name: "AppsFlyerLib", package: "AppsFlyerFramework")],
            resources: [.process("Resources")]
        ),
        .testTarget(name: "SnitchTests", dependencies: ["Snitch"]),
        .testTarget(name: "SnitchPostHogTests", dependencies: ["SnitchPostHog"]),
        .testTarget(name: "SnitchAppsFlyerTests", dependencies: ["SnitchAppsFlyer"]),
    ]
)
