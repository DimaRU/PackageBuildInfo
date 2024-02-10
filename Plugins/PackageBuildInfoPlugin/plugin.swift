/////
////  plugin.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

import PackagePlugin
import Foundation

@main
struct PackageBuildInfoPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        guard let target = target as? SourceModuleTarget else { return [] }
        let outputFile = context.pluginWorkDirectory.appending("packageBuildInfo.swift")

        let command: Command = .prebuildCommand(
            displayName:
                "Generating \(outputFile.lastComponent) for \(target.directory)",
            executable:
                try context.tool(named: "PackageBuildInfo").path,
            arguments: [ "\(target.directory)", "\(outputFile)" ],
            outputFilesDirectory: context.pluginWorkDirectory
        )
        return [command]
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin
extension PackageBuildInfoPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodeProjectPlugin.XcodePluginContext, target: XcodeProjectPlugin.XcodeTarget) throws -> [PackagePlugin.Command] {
        let outputFile = context.pluginWorkDirectory.appending("packageBuildInfo.swift")
        let command: Command = .prebuildCommand(
            displayName:
                "Generating \(outputFile.lastComponent) for \(context.xcodeProject.directory)",
            executable:
                try context.tool(named: "PackageBuildInfo").path,
            arguments: [ "\(context.xcodeProject.directory)", "\(outputFile)" ],
            outputFilesDirectory: context.pluginWorkDirectory
        )
        return [command]
    }
}
#endif
