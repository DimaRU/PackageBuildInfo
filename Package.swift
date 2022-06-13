// swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "PackageBuildInfo",
    products: [
        .plugin(name: "PackageBuildInfoPlugin", targets: ["PackageBuildInfoPlugin"]),
    ],
    targets: [
        .plugin(
            name: "PackageBuildInfoPlugin",
            capability: .buildTool(),
            dependencies: ["PackageBuildInfo"]
        ),
        .binaryTarget(name: "PackageBuildInfo", path: "Binaries/PackageBuildInfo.zip"),
    ]
)
