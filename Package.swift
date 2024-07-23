// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "1.2.0"
let moduleName = "DXFeedFramework"
let checksum = "ca65364fc0c8e322942e4bd3aec8328e1cbc29574ee15fa8c4efc64bf155d271"

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
