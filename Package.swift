// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MBNetworking",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "MBNetworking",
            targets: ["MBNetworking"])
    ],
    dependencies: [
        .package(url: "https://github.com/mobven/MBErrorKit.git", .branch("develop"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package,
        // and on products in packages which this package depends on.
        .target(
            name: "MBNetworking",
            dependencies: ["MBErrorKit"]),
        .testTarget(
            name: "MBNetworkingTests",
            dependencies: ["MBNetworking"],
            resources: [
                .copy("Resources/results.json"),
                .copy("Resources/httpError.json"),
                .copy("Resources/imageDownload.jpg"),
                .copy("Resources/some.txt")
            ])
    ]
)
