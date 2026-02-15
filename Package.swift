// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ContextKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "ContextKit",
            targets: ["ContextKit"]),
    ],
    dependencies: [
        // Zero dependencies for maximum adoption
    ],
    targets: [
        .target(
            name: "ContextKit",
            dependencies: [],
            path: "Sources/ContextKit",
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "ContextKitTests",
            dependencies: ["ContextKit"],
            path: "Tests/ContextKitTests"
        ),
    ]
)
