// archiver.swift
import Foundation

func checkRarInstalled() -> Bool {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["rar", "--version"]
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe
    try? process.run()
    process.waitUntilExit()
    if process.terminationStatus != 0 {
        print("Error: 'rar' command not found. Please install WinRAR or RAR tools.")
        return false
    }
    return true
}

func runRarCommand(_ args: [String]) -> Bool {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["rar"] + args
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe
    do {
        try process.run()
        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            print(output)
        }
        return process.terminationStatus == 0
    } catch {
        print("RAR error: \(error)")
        return false
    }
}

func createArchive(_ archive: String, files: [String], password: String? = nil, solid: Bool = false, recovery: Bool = false, threads: Int? = nil) -> Bool {
    var args = ["a"]
    if let pwd = password { args.append("-hp\(pwd)") }
    if solid { args.append("-s") }
    if recovery { args.append("-rr") }
    if let t = threads { args.append("-mt\(t)") }
    args.append(archive)
    args.append(contentsOf: files)
    return runRarCommand(args)
}

func extractArchive(_ archive: String, outputDir: String = ".") -> Bool {
    var args = ["x", archive]
    if outputDir != "." { args.append(outputDir) }
    return runRarCommand(args)
}

func listArchive(_ archive: String) -> Bool {
    return runRarCommand(["l", archive])
}

func addFiles(_ archive: String, files: [String]) -> Bool {
    return runRarCommand(["a", archive] + files)
}

func deleteFiles(_ archive: String, files: [String]) -> Bool {
    return runRarCommand(["d", archive] + files)
}

func archiveInfo(_ archive: String) -> Bool {
    return runRarCommand(["v", archive])
}

func parseOptions(_ args: [String]) -> (args: [String], password: String?, solid: Bool, recovery: Bool, threads: Int?) {
    var result: [String] = []
    var password: String? = nil
    var solid = false, recovery = false
    var threads: Int? = nil
    var i = 0
    while i < args.count {
        switch args[i] {
        case "--password":
            if i+1 < args.count { password = args[i+1]; i += 2 } else { i += 1 }
        case "--solid":
            solid = true; i += 1
        case "--recovery":
            recovery = true; i += 1
        case "--threads":
            if i+1 < args.count { threads = Int(args[i+1]); i += 2 } else { i += 1 }
        default:
            result.append(args[i]); i += 1
        }
    }
    return (result, password, solid, recovery, threads)
}

func main() {
    let args = CommandLine.arguments.dropFirst()
    if args.count < 1 {
        print("""
        Usage: swift archiver.swift <command> [options]
        Commands:
          create archive.rar file1 file2 ...
          extract archive.rar [output_dir]
          list archive.rar
          add archive.rar file1 file2 ...
          delete archive.rar file1 file2 ...
          info archive.rar
        Options:
          --password PWD   Protect with password
          --solid          Use solid archiving
          --recovery       Add recovery records
          --threads N      Number of threads
        """)
        exit(1)
    }

    guard checkRarInstalled() else { exit(1) }

    let cmd = args.first!
    let rest = Array(args.dropFirst())
    let (cmdArgs, password, solid, recovery, threads) = parseOptions(rest)

    switch cmd {
    case "create":
        guard cmdArgs.count >= 2 else {
            print("Usage: create archive.rar file1 file2 ...")
            exit(1)
        }
        let archive = cmdArgs[0]
        let files = Array(cmdArgs.dropFirst())
        _ = createArchive(archive, files: files, password: password, solid: solid, recovery: recovery, threads: threads)
    case "extract":
        guard cmdArgs.count >= 1 else {
            print("Usage: extract archive.rar [output_dir]")
            exit(1)
        }
        let archive = cmdArgs[0]
        let outputDir = cmdArgs.count > 1 ? cmdArgs[1] : "."
        _ = extractArchive(archive, outputDir: outputDir)
    case "list":
        guard cmdArgs.count >= 1 else {
            print("Usage: list archive.rar")
            exit(1)
        }
        _ = listArchive(cmdArgs[0])
    case "add":
        guard cmdArgs.count >= 2 else {
            print("Usage: add archive.rar file1 file2 ...")
            exit(1)
        }
        let archive = cmdArgs[0]
        let files = Array(cmdArgs.dropFirst())
        _ = addFiles(archive, files: files)
    case "delete":
        guard cmdArgs.count >= 2 else {
            print("Usage: delete archive.rar file1 file2 ...")
            exit(1)
        }
        let archive = cmdArgs[0]
        let files = Array(cmdArgs.dropFirst())
        _ = deleteFiles(archive, files: files)
    case "info":
        guard cmdArgs.count >= 1 else {
            print("Usage: info archive.rar")
            exit(1)
        }
        _ = archiveInfo(cmdArgs[0])
    default:
        print("Unknown command: \(cmd)")
    }
}

main()
