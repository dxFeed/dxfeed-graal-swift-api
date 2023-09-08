// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.0.10_build"
let moduleName = "DXFeedFramework"
let checksum = "c4049e3377504cdfcadab6e83ee4faf604498b6156c5e329716bc66c1726a0e4"

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
