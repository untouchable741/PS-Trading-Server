// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "PS-Trading",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/MihaelIsaev/FCM.git", from: "0.6.2"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.1"),
        .package(url: "https://github.com/LiveUI/S3.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentMySQL", "Vapor", "Vapor", "FCM", "Authentication", "S3"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

