// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PInject",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13)
    ],
    products: [
        .library(
            name: "PInject",
            targets: ["PInject"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "PInject",
            path: "./PInject.xcframework"
        )
    ],
    swiftLanguageModes: [.v5]
)
