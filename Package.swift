// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "1.1.2_build"
let moduleName = "DXFeedFramework"
let checksum = "737340cb0065a223cbf4d0dd6f9e0ac241f78d3489c6e36b980bbad9609745bb"

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
