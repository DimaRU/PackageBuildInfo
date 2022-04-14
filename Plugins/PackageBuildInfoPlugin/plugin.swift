/////
////  plugin.swift
///   Copyright © 2022 Dmitriy Borovikov. All rights reserved.
//

import PackagePlugin
import Foundation

@main
struct PackageBuildInfoPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        func searchTool() -> String? {
            let mintPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".mint/bin")
            let pathList = (ProcessInfo.processInfo.environment["PATH"] ?? "/usr/local/bin") + ":\(mintPath.path)"
            
            for path in pathList.split(separator: ":") {
                let url = URL(fileURLWithPath: String(path)).appendingPathComponent("packageBuildInfo")
                if let res = try? url.resourceValues(forKeys: [.isExecutableKey]),
                   res.isExecutable ?? false
                {
                    return url.path
                }
            }
            return nil
        }
        
        guard let target = target as? SourceModuleTarget else { return [] }
        guard let tool = searchTool() else {
            Diagnostics.error("Please install PackageBuildInfo")
            return []
        }
        let outputFile = context.pluginWorkDirectory.appending("packageBuildInfo.swift")

        let command: Command = .prebuildCommand(
            displayName:
                "Generating \(outputFile.lastComponent) for \(target.directory)",
            executable:
                PackagePlugin.Path(tool),
            arguments: [ "\(target.directory)", "\(outputFile)" ],
            outputFilesDirectory: context.pluginWorkDirectory
        )
        return [command]
    }
}
