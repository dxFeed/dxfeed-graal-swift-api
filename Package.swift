// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "1.0.1_build"
let moduleName = "DXFeedFramework"
let checksum = "68a73daad279e200be8b54021725cceae5ad044359531c1130356d68bebdd3c1"

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
