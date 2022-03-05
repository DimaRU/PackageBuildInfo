// swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "BuildInfo",
    platforms: [.macOS(.v11)],
    products: [
        .plugin(name: "BuildInfoPlugin", targets: ["BuildInfoPlugin"]),
        .executable(name: "BuildInfo", targets: ["BuildInfo"]),
    ],
    targets: [
        .plugin(
            name: "BuildInfoPlugin",
            capability: .buildTool(),
            dependencies: ["BuildInfo"]
        ),
        .executableTarget(name: "BuildInfo"),
    ]
)
