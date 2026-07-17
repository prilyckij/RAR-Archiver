// archiver.go
package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"strconv"
	"strings"
)

func checkRarInstalled() bool {
	_, err := exec.LookPath("rar")
	if err != nil {
		fmt.Println("Error: 'rar' command not found. Please install WinRAR or RAR tools.")
		return false
	}
	return true
}

func runRarCommand(args []string) bool {
	cmd := exec.Command("rar", args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	if err != nil {
		fmt.Println("RAR error:", err)
		return false
	}
	return true
}

func createArchive(archive string, files []string, password string, solid bool, recovery bool, threads int) bool {
	args := []string{"a"}
	if password != "" {
		args = append(args, "-hp"+password)
	}
	if solid {
		args = append(args, "-s")
	}
	if recovery {
		args = append(args, "-rr")
	}
	if threads > 0 {
		args = append(args, "-mt"+strconv.Itoa(threads))
	}
	args = append(args, archive)
	args = append(args, files...)
	return runRarCommand(args)
}

func extractArchive(archive string, outputDir string) bool {
	args := []string{"x", archive}
	if outputDir != "" && outputDir != "." {
		args = append(args, outputDir)
	}
	return runRarCommand(args)
}

func listArchive(archive string) bool {
	args := []string{"l", archive}
	return runRarCommand(args)
}

func addFiles(archive string, files []string) bool {
	args := []string{"a", archive}
	args = append(args, files...)
	return runRarCommand(args)
}

func deleteFiles(archive string, files []string) bool {
	args := []string{"d", archive}
	args = append(args, files...)
	return runRarCommand(args)
}

func archiveInfo(archive string) bool {
	args := []string{"v", archive}
	return runRarCommand(args)
}

func parseOptions(args []string) ([]string, string, bool, bool, int) {
	var result []string
	password := ""
	solid := false
	recovery := false
	threads := 0
	for i := 0; i < len(args); i++ {
		switch args[i] {
		case "--password":
			if i+1 < len(args) {
				password = args[i+1]
				i++
			}
		case "--solid":
			solid = true
		case "--recovery":
			recovery = true
		case "--threads":
			if i+1 < len(args) {
				threads, _ = strconv.Atoi(args[i+1])
				i++
			}
		default:
			result = append(result, args[i])
		}
	}
	return result, password, solid, recovery, threads
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println(`Usage: archiver.go <command> [options]
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
  --threads N      Number of threads`)
		os.Exit(1)
	}

	if !checkRarInstalled() {
		os.Exit(1)
	}

	cmd := os.Args[1]
	args := os.Args[2:]
	args, password, solid, recovery, threads := parseOptions(args)

	switch cmd {
	case "create":
		if len(args) < 2 {
			fmt.Println("Usage: create archive.rar file1 file2 ...")
			return
		}
		archive := args[0]
		files := args[1:]
		createArchive(archive, files, password, solid, recovery, threads)
	case "extract":
		if len(args) < 1 {
			fmt.Println("Usage: extract archive.rar [output_dir]")
			return
		}
		archive := args[0]
		outputDir := "."
		if len(args) > 1 {
			outputDir = args[1]
		}
		extractArchive(archive, outputDir)
	case "list":
		if len(args) < 1 {
			fmt.Println("Usage: list archive.rar")
			return
		}
		listArchive(args[0])
	case "add":
		if len(args) < 2 {
			fmt.Println("Usage: add archive.rar file1 file2 ...")
			return
		}
		archive := args[0]
		files := args[1:]
		addFiles(archive, files)
	case "delete":
		if len(args) < 2 {
			fmt.Println("Usage: delete archive.rar file1 file2 ...")
			return
		}
		archive := args[0]
		files := args[1:]
		deleteFiles(archive, files)
	case "info":
		if len(args) < 1 {
			fmt.Println("Usage: info archive.rar")
			return
		}
		archiveInfo(args[0])
	default:
		fmt.Printf("Unknown command: %s\n", cmd)
	}
}
