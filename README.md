🗜️ RAR Archiver – Multi‑Language Edition
A powerful RAR archiver that creates, extracts, and manages RAR archives using the system's rar command-line tool.
Supports compression, extraction, listing, adding/removing files, and archive information.
Built in 7 programming languages – each implementation wraps the same powerful RAR backend.

✨ Features
Create RAR archive – compress files/folders with optional password protection.

Extract RAR archive – extract to current directory or a specified path.

List contents – view files inside a RAR archive without extracting.

Add files – append new files to an existing RAR archive.

Delete files – remove specific files from an archive.

Archive info – display compression ratio, file count, and size.

Multi‑threading – uses -mt flag for faster compression on multi-core systems.

Recovery records – add -rr for data recovery (optional).

Solid archiving – use -s for better compression (optional).

Cross‑platform – works on Windows, macOS, and Linux (with RAR tools installed).

🗂 Languages & Files
Language	File
Python	archiver.py
Go	archiver.go
JavaScript (Node)	archiver.js
C#	Archiver.cs
Java	Archiver.java
Ruby	archiver.rb
Swift	archiver.swift
🚀 How to Run
Each file is standalone – run it with the appropriate interpreter/compiler.

Prerequisite: The rar command-line tool must be installed:

Windows: Install WinRAR and add to PATH.

macOS: brew install rar (or use rar from rarlab.com).

Linux: sudo apt install rar (or unrar for extraction only).

Language	Command
Python	python archiver.py create archive.rar file1.txt folder/
Go	go run archiver.go create archive.rar file1.txt folder/
JavaScript	node archiver.js create archive.rar file1.txt folder/
C#	dotnet run -- create archive.rar file1.txt folder/
Java	javac Archiver.java && java Archiver create archive.rar file1.txt folder/
Ruby	ruby archiver.rb create archive.rar file1.txt folder/
Swift	swift archiver.swift create archive.rar file1.txt folder/
🎮 Commands
create <archive.rar> <file/dir> [<file/dir>...] – create a new RAR archive.

extract <archive.rar> [output_dir] – extract archive (default: current directory).

list <archive.rar> – show contents of the archive.

add <archive.rar> <file> [<file>...] – add files to an existing archive.

delete <archive.rar> <file> [<file>...] – remove files from an archive.

info <archive.rar> – display archive information.

🛠️ Options
Option	Description
--password PWD	Protect the archive with a password
--solid	Use solid archiving (better compression)
--recovery	Add recovery records (data recovery)
--threads N	Set number of threads for compression
📜 License
MIT – use freely.
