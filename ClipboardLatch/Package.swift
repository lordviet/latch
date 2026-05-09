// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ClipboardLatch",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "ClipboardLatch",
            targets: ["ClipboardLatch"]
        )
    ],
    targets: [
        .executableTarget(
            name: "ClipboardLatch",
            path: "Sources"
        )
    ]
)
