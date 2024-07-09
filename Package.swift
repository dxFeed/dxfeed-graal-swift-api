// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "1.1.4"
let moduleName = "DXFeedFramework"
let checksum = "c012375b0990e9940ce44bc3ab60b93278c881b973ac6f2a046bea7b874e6515"

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
