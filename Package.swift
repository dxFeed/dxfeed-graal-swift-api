// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "1.5.0"
let moduleName = "DXFeedFramework"
let checksum = "002bd9096b967096ca994cec3ab8826c368eb1edbaf584928cd5628a2fcd0e84"

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
