// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NodePersonApple",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "NodePersonShared",
            targets: ["NodePersonShared"]
        ),
    ],
    targets: [
        // ── Shared Library (all platforms) ──
        .target(
            name: "NodePersonShared",
            path: "Sources/NodePersonShared"
        ),
    ]
)
