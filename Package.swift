// swift-tools-version:5.9

//
// Copyright 2020-2021 Signal Messenger, LLC.
// SPDX-License-Identifier: AGPL-3.0-only
//

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "LibSignalClient",
    platforms: [
        .macOS(.v10_15), .iOS(.v13),
    ],
    products: [
        .library(
            name: "LibSignalClient",
            targets: ["LibSignalClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "LibSignalClient",
            dependencies: ["SignalFfi"],
            path: "swift/Sources",
            exclude: ["LibSignalClient/Logging.m"]
        ),
        .testTarget(
            name: "LibSignalClientTests",
            dependencies: ["LibSignalClient"],
            path: "swift/Tests"
        ),
        .binaryTarget(
            name: "SignalFfi",
            url: "https://github.com/lucaslimapoa/libsignal/releases/download/v0.44.0-spm/SignalFfi.xcframework.zip",
            checksum: "2ed5cc98951dd99dbefb0c315c30878d022a272338f61369531ee9b74453c2a6"
        ),
    ]
)
