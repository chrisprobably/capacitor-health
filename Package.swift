// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ChrisprobablyCapacitorHealth",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "ChrisprobablyCapacitorHealth",
            targets: ["HealthPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "HealthPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/HealthPlugin",
            linkerSettings: [
                .linkedFramework("HealthKit")
            ]),
        .testTarget(
            name: "HealthPluginTests",
            dependencies: ["HealthPlugin"],
            path: "ios/Tests/HealthPluginTests")
    ]
)
