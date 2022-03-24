import Foundation

main()

func main() {
    if CommandLine.argc < 2 {
        print("USAGE: packageBuildInfo <git directory> [<output file>]")
        exit(1)
    }
    let gitDirectory = URL(fileURLWithPath: CommandLine.arguments[1])
    let outputFile: URL?
    if CommandLine.argc == 2 {
        outputFile = nil
    } else {
        outputFile = URL(fileURLWithPath: CommandLine.arguments[2])
    }
    guard
        let gitInfo = GitInfoCoder(gitDirectory: gitDirectory, outputFile: outputFile)
    else {
        exit(1)
    }
    gitInfo.codegen()
}
