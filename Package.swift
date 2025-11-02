// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "CloudKitJSON",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "CloudKitJSON",
            targets: ["CloudKitJSON"]
        ),
    ],
    targets: [
        .target(
            name: "CloudKitJSON"
        ),
        .testTarget(
            name: "CloudKitJSONTests",
            dependencies: ["CloudKitJSON"]
        ),
    ]
)
