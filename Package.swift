// swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "PackageBuildInfo",
    platforms: [.macOS(.v11)],
    products: [
        .plugin(name: "packageBuildInfoPlugin", targets: ["PackageBuildInfoPlugin"]),
        .executable(name: "packageBuildInfo", targets: ["PackageBuildInfo"]),
    ],
    targets: [
        .plugin(
            name: "PackageBuildInfoPlugin",
            capability: .buildTool(),
            dependencies: ["PackageBuildInfo"]
        ),
        .executableTarget(name: "PackageBuildInfo"),
    ]
)
