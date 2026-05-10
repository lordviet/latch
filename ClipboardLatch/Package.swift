// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Latch",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "Latch",
            targets: ["Latch"]
        )
    ],
    targets: [
        .executableTarget(
            name: "Latch",
            path: "Sources"
        )
    ]
)
