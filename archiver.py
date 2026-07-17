# archiver.py
import subprocess
import sys
import os
import shlex
import platform

def check_rar_installed():
    try:
        subprocess.run(['rar', '--version'], capture_output=True, check=True)
        return True
    except:
        print("Error: 'rar' command not found. Please install WinRAR or RAR tools.")
        return False

def run_rar_command(args):
    cmd = ['rar'] + args
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"RAR error: {result.stderr}")
        return False
    print(result.stdout)
    return True

def create_archive(archive, files, password=None, solid=False, recovery=False, threads=None):
    args = ['a']
    if password:
        args.extend(['-hp' + password])
    if solid:
        args.append('-s')
    if recovery:
        args.append('-rr')
    if threads:
        args.append('-mt' + str(threads))
    args.append(archive)
    args.extend(files)
    return run_rar_command(args)

def extract_archive(archive, output_dir='.'):
    args = ['x', archive, output_dir]
    return run_rar_command(args)

def list_archive(archive):
    args = ['l', archive]
    return run_rar_command(args)

def add_files(archive, files):
    args = ['a', archive] + files
    return run_rar_command(args)

def delete_files(archive, files):
    args = ['d', archive] + files
    return run_rar_command(args)

def archive_info(archive):
    args = ['v', archive]
    return run_rar_command(args)

def main():
    if len(sys.argv) < 2:
        print("Usage: archiver.py <command> [options]")
        print("Commands:")
        print("  create archive.rar file1 file2 ...")
        print("  extract archive.rar [output_dir]")
        print("  list archive.rar")
        print("  add archive.rar file1 file2 ...")
        print("  delete archive.rar file1 file2 ...")
        print("  info archive.rar")
        print("Options:")
        print("  --password PWD   Protect with password")
        print("  --solid          Use solid archiving")
        print("  --recovery       Add recovery records")
        print("  --threads N      Number of threads")
        sys.exit(1)

    if not check_rar_installed():
        sys.exit(1)

    cmd = sys.argv[1]
    args = sys.argv[2:]
    
    # Parse options
    password = None
    solid = False
    recovery = False
    threads = None
    i = 0
    while i < len(args):
        if args[i] == '--password' and i+1 < len(args):
            password = args[i+1]
            args.pop(i); args.pop(i)
            continue
        elif args[i] == '--solid':
            solid = True
            args.pop(i)
            continue
        elif args[i] == '--recovery':
            recovery = True
            args.pop(i)
            continue
        elif args[i] == '--threads' and i+1 < len(args):
            threads = int(args[i+1])
            args.pop(i); args.pop(i)
            continue
        i += 1

    if cmd == 'create' and len(args) >= 2:
        archive = args[0]
        files = args[1:]
        create_archive(archive, files, password, solid, recovery, threads)
    elif cmd == 'extract' and len(args) >= 1:
        archive = args[0]
        output_dir = args[1] if len(args) > 1 else '.'
        extract_archive(archive, output_dir)
    elif cmd == 'list' and len(args) >= 1:
        list_archive(args[0])
    elif cmd == 'add' and len(args) >= 2:
        archive = args[0]
        files = args[1:]
        add_files(archive, files)
    elif cmd == 'delete' and len(args) >= 2:
        archive = args[0]
        files = args[1:]
        delete_files(archive, files)
    elif cmd == 'info' and len(args) >= 1:
        archive_info(args[0])
    else:
        print(f"Unknown command or insufficient arguments: {cmd}")

if __name__ == '__main__':
    main()
