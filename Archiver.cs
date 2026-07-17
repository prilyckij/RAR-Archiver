// Archiver.cs
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;

class Archiver
{
    static bool CheckRarInstalled()
    {
        try
        {
            Process.Start(new ProcessStartInfo("rar", "--version") { UseShellExecute = false })?.WaitForExit();
            return true;
        }
        catch
        {
            Console.WriteLine("Error: 'rar' command not found. Please install WinRAR or RAR tools.");
            return false;
        }
    }

    static bool RunRarCommand(string args)
    {
        try
        {
            var process = Process.Start(new ProcessStartInfo("rar", args)
            {
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true
            });
            process.OutputDataReceived += (sender, e) => Console.WriteLine(e.Data);
            process.ErrorDataReceived += (sender, e) => Console.Error.WriteLine(e.Data);
            process.BeginOutputReadLine();
            process.BeginErrorReadLine();
            process.WaitForExit();
            return process.ExitCode == 0;
        }
        catch (Exception e)
        {
            Console.WriteLine($"RAR error: {e.Message}");
            return false;
        }
    }

    static bool CreateArchive(string archive, string[] files, string password, bool solid, bool recovery, int threads)
    {
        var args = new List<string> { "a" };
        if (!string.IsNullOrEmpty(password)) args.Add($"-hp{password}");
        if (solid) args.Add("-s");
        if (recovery) args.Add("-rr");
        if (threads > 0) args.Add($"-mt{threads}");
        args.Add(archive);
        args.AddRange(files);
        return RunRarCommand(string.Join(" ", args));
    }

    static bool ExtractArchive(string archive, string outputDir)
    {
        var args = $"x {archive}";
        if (!string.IsNullOrEmpty(outputDir) && outputDir != ".")
            args += $" {outputDir}";
        return RunRarCommand(args);
    }

    static bool ListArchive(string archive) => RunRarCommand($"l {archive}");
    static bool AddFiles(string archive, string[] files) => RunRarCommand($"a {archive} {string.Join(" ", files)}");
    static bool DeleteFiles(string archive, string[] files) => RunRarCommand($"d {archive} {string.Join(" ", files)}");
    static bool ArchiveInfo(string archive) => RunRarCommand($"v {archive}");

    static (string[] args, string password, bool solid, bool recovery, int threads) ParseOptions(string[] args)
    {
        var result = new List<string>();
        string password = "";
        bool solid = false, recovery = false;
        int threads = 0;
        for (int i = 0; i < args.Length; i++)
        {
            if (args[i] == "--password" && i + 1 < args.Length)
            {
                password = args[++i];
            }
            else if (args[i] == "--solid")
            {
                solid = true;
            }
            else if (args[i] == "--recovery")
            {
                recovery = true;
            }
            else if (args[i] == "--threads" && i + 1 < args.Length)
            {
                int.TryParse(args[++i], out threads);
            }
            else
            {
                result.Add(args[i]);
            }
        }
        return (result.ToArray(), password, solid, recovery, threads);
    }

    static void Main(string[] args)
    {
        if (args.Length < 1)
        {
            Console.WriteLine(@"Usage: Archiver.exe <command> [options]
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
  --threads N      Number of threads");
            return;
        }

        if (!CheckRarInstalled()) return;

        string cmd = args[0];
        var rest = args.Skip(1).ToArray();
        var (cmdArgs, password, solid, recovery, threads) = ParseOptions(rest);

        switch (cmd.ToLower())
        {
            case "create":
                if (cmdArgs.Length < 2) { Console.WriteLine("Usage: create archive.rar file1 file2 ..."); return; }
                CreateArchive(cmdArgs[0], cmdArgs.Skip(1).ToArray(), password, solid, recovery, threads);
                break;
            case "extract":
                if (cmdArgs.Length < 1) { Console.WriteLine("Usage: extract archive.rar [output_dir]"); return; }
                ExtractArchive(cmdArgs[0], cmdArgs.Length > 1 ? cmdArgs[1] : ".");
                break;
            case "list":
                if (cmdArgs.Length < 1) { Console.WriteLine("Usage: list archive.rar"); return; }
                ListArchive(cmdArgs[0]);
                break;
            case "add":
                if (cmdArgs.Length < 2) { Console.WriteLine("Usage: add archive.rar file1 file2 ..."); return; }
                AddFiles(cmdArgs[0], cmdArgs.Skip(1).ToArray());
                break;
            case "delete":
                if (cmdArgs.Length < 2) { Console.WriteLine("Usage: delete archive.rar file1 file2 ..."); return; }
                DeleteFiles(cmdArgs[0], cmdArgs.Skip(1).ToArray());
                break;
            case "info":
                if (cmdArgs.Length < 1) { Console.WriteLine("Usage: info archive.rar"); return; }
                ArchiveInfo(cmdArgs[0]);
                break;
            default:
                Console.WriteLine($"Unknown command: {cmd}");
                break;
        }
    }
}
