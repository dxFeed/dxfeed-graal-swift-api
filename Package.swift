// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "1.1.4"
let moduleName = "DXFeedFramework"
let checksum = "5d7de73e6eab7e8e522a6f9ee5cc31d1014b3d5274f3c9b222721baf4f8984ee"

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
            url: "https://dxfeed.jfrog.io/artifactory/spm-open/binary/dxfeed-xcframework/dxfeed-xcframework-\(version).zip",
            checksum: checksum
        )
    ]
)
