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
    ],
    targets: [
        .target(name: "Snitch", resources: [.process("Resources")]),
        .testTarget(name: "SnitchTests", dependencies: ["Snitch"]),
    ]
)
