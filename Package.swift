// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.0.9_build"
let moduleName = "DXFeedFramework"
let checksum = "257a5d568ee0a5942c885dc9f1eee05788694160f68b2c2e29897cd16f5f38c5"

let package = Package(
    name: moduleName,
    products: [
        .library(
            name: moduleName,
            targets: [moduleName]
        )
    ],
    targets: [
        .binaryTarget(
            name: moduleName,
            url: "https://github.com/dxFeed/dxfeed-graal-swift-api/releases/download/\(version)/\(moduleName).zip",
            checksum: checksum
        )
    ]
)
