// swift-tools-version: 5.10
import PackageDescription

let featureFlags: [SwiftSetting] = [
    .enableExperimentalFeature("StrictConcurrency=complete"),
    .enableUpcomingFeature("StrictConcurrency=complete"),
    .enableUpcomingFeature("ExistentialAny"),
]

let package = Package(
    name: "hummingbird-elementary",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10),
    ],
    products: [
        .library(
            name: "HummingbirdElementary",
            targets: ["HummingbirdElementary"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0"),
        .package(url: "https://github.com/sliemeobn/elementary.git", .upToNextMajor(from: "0.3.0")),
    ],
    targets: [
        .target(
            name: "HummingbirdElementary",
            dependencies: [
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "Elementary", package: "elementary"),
            ],
            swiftSettings: featureFlags
        ),
        .testTarget(
            name: "HummingbirdElementaryTests",
            dependencies: [
                .target(name: "HummingbirdElementary"),
                .product(name: "Elementary", package: "elementary"),
                .product(name: "HummingbirdTesting", package: "hummingbird"),
            ],
            swiftSettings: featureFlags
        ),
    ]
)
