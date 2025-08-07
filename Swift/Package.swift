// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "swift-kotlin-consumer",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(name: "Kotlib", path: "../build")
    ],
    targets: [
        .executableTarget(name: "kotlin-consumer", dependencies: ["Kotlib"]),
        .testTarget(name: "kotlin-consumer-tests",dependencies: ["Kotlib"])
    ]
)
