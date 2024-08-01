// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "1.3.0"
let moduleName = "DXFeedFramework"
let checksum = "63316ac8a598454451e92db39310a8646210cbe320f595c64395e05bf9474607"

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
