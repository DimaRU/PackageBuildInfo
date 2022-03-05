import PackagePlugin
import Foundation

@main
struct MyPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {

        func searchGit() -> URL? {
            let pathList = ProcessInfo.processInfo.environment["PATH"] ?? "/usr/bin"
            
            for path in pathList.split(separator: ":") {
                let gitURL = URL(fileURLWithPath: String(path)).appendingPathComponent("git")
                if let res = try? gitURL.resourceValues(forKeys: [.isExecutableKey]),
                   res.isExecutable ?? false
                {
                    return gitURL
                }
            }
            return nil
        }

        let currentDirectory = URL(fileURLWithPath: target.directory.string)
        guard let git = searchGit() else {
            Diagnostics.error("Git not found in PATH")
            return []
        }

        func runGit(command: String) throws -> (exitCode: Int32, output: String) {
            let process = Process()
            process.executableURL = git
            process.currentDirectoryURL = currentDirectory
            
            let stdinPipe = Pipe()
            let stdErrPipe = Pipe()
            process.standardOutput = stdinPipe
            process.standardError = stdErrPipe
            process.arguments = command.split(separator: " ").map { String($0) }
            try process.run()
            process.waitUntilExit()
            let status = process.terminationStatus
            
            let data = try stdinPipe.fileHandleForReading.readToEnd() ?? Data()
            let output = (String(data: data, encoding: .utf8) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            return (exitCode: status, output: output)
        }
        
        print("Hello from the Build Info Plugin!")
        print("PluginContext:\n\(context)")
        guard let target = target as? SourceModuleTarget else { return [] }
        print("moduleName: \(target.moduleName)")
        print("directory: \(target.directory.string)")

        let outputFile = context.pluginWorkDirectory.appending("buildInfo.swift")

        let command: PackagePlugin.Command
        let (exitCode, output) = try runGit(command: "git status --porcelain -uno")
        if exitCode == 0, output.isEmpty {
            command = .prebuildCommand(
                displayName:
                    "Generating \(Date()) \(outputFile.lastComponent) for \(target.directory)",
                executable:
                    try context.tool(named: "BuildInfo").path,
                arguments: [ "\(target.directory)", "\(outputFile)", "\(Date())" ],
                outputFilesDirectory: context.pluginWorkDirectory
            )
        } else {
            command = .buildCommand(
                displayName:
                    "Generating \(Date()) \(outputFile.lastComponent) for dirty \(target.directory)",
                executable:
                    try context.tool(named: "BuildInfo").path,
                arguments: [ "\(target.directory)", "\(outputFile)", "\(Date())" ],
                inputFiles: target.sourceFiles.map{ $0.path },
                outputFiles: [ outputFile ]
            )
        }
        return [command]
    }
}

extension PluginContext: CustomStringConvertible {
    public var description: String {
        """
        pluginWorkDirectory: \(self.pluginWorkDirectory)
        package.displayName: \(self.package.displayName)
        tool: \(try! self.tool(named: "BuildInfo"))
        """
    }
}
