// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.0.77"
let moduleName = "DXFeedFramework"
let checksum = "39f0525aa272ea7903d0e860bad4bcfa16ceee6ac474cfb28a2fea3290387e66"

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
            url: "https://dxfeed.jfrog.io/artifactory/dxfeed-graal-open/binary/dxfeed-xcframework/dxfeed-xcframework-\(version).zip",
            checksum: checksum
        )
    ]
)
