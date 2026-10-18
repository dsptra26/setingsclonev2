// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SettingsClone",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "SettingsClone",
            targets: ["SettingsClone"]),
    ],
    targets: [
        .target(
            name: "SettingsClone",
            path: "Sources/SettingsClone")
    ]
)
