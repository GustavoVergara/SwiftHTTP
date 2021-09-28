// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HTTP",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "HTTP",
            targets: ["HTTP"]),
        .library(
            name: "HTTPTestKit",
            targets: ["HTTPTestKit"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "HTTP",
            dependencies: []),
        .target(
            name: "HTTPTestKit",
            dependencies: ["HTTP"]),
        .testTarget(
            name: "HTTPTests",
            dependencies: ["HTTP", "HTTPTestKit"]),
    ]
)
