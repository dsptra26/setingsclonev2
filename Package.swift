// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SettingsClone",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .executable(
            name: "SettingsClone",
            targets: ["SettingsClone"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "SettingsClone",
            path: "Sources/SettingsClone"
        )
    ]
)
