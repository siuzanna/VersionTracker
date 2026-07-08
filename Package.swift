// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VersionTracker",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "VersionTracker", targets: ["VersionTracker"]),
        .library(name: "VersionTrackerUI", targets: ["VersionTrackerUI"])
    ],
    targets: [
        .target(name: "VersionTracker"),
        .target(name: "VersionTrackerUI", dependencies: ["VersionTracker"]),
        .testTarget(name: "VersionTrackerTests", dependencies: ["VersionTracker"])
    ]
)
