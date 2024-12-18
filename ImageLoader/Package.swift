// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ImageLoader",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ImageLoader",
            targets: ["ImageLoader"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ImageLoader"),
        .testTarget(
            name: "ImageLoaderTests",
            dependencies: ["ImageLoader"]),
        .testTarget(
            name: "ImageLoaderIntegrationTests",
            dependencies: ["ImageLoader"]),
    ]
)
