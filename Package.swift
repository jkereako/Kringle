// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Kringle",
    products: [
        .library(
            name: "Kringle",
            targets: ["Kringle"]),
    ],
    dependencies: [
       .package(url: "https://github.com/google/promises.git", from: "1.2.7")
    ],
    targets: [
        .target(
            name: "Kringle",
            dependencies: ["Promises"]
        ),
        .testTarget(
            name: "KringleTests",
            dependencies: ["Kringle"],
            path: "Tests/UnitTests"
        )
    ]
)
