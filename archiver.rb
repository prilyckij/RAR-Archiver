# archiver.rb
require 'open3'

def check_rar_installed
  system('rar --version > /dev/null 2>&1')
  unless $?.success?
    puts "Error: 'rar' command not found. Please install WinRAR or RAR tools."
    return false
  end
  true
end

def run_rar_command(args)
  cmd = ['rar'] + args
  stdout, stderr, status = Open3.capture3(*cmd)
  puts stdout
  puts stderr unless stderr.empty?
  status.success?
end

def create_archive(archive, files, password: nil, solid: false, recovery: false, threads: nil)
  args = ['a']
  args << "-hp#{password}" if password
  args << '-s' if solid
  args << '-rr' if recovery
  args << "-mt#{threads}" if threads
  args << archive
  args += files
  run_rar_command(args)
end

def extract_archive(archive, output_dir = '.')
  args = ['x', archive]
  args << output_dir if output_dir != '.'
  run_rar_command(args)
end

def list_archive(archive)
  run_rar_command(['l', archive])
end

def add_files(archive, files)
  run_rar_command(['a', archive] + files)
end

def delete_files(archive, files)
  run_rar_command(['d', archive] + files)
end

def archive_info(archive)
  run_rar_command(['v', archive])
end

def parse_options(args)
  result = []
  password = nil
  solid = false
  recovery = false
  threads = nil
  i = 0
  while i < args.length
    case args[i]
    when '--password'
      password = args[i+1]
      i += 2
    when '--solid'
      solid = true
      i += 1
    when '--recovery'
      recovery = true
      i += 1
    when '--threads'
      threads = args[i+1].to_i
      i += 2
    else
      result << args[i]
      i += 1
    end
  end
  [result, password, solid, recovery, threads]
end

if ARGV.length < 1
  puts <<~HELP
    Usage: ruby archiver.rb <command> [options]
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
  HELP
  exit 1
end

unless check_rar_installed
  exit 1
end

cmd = ARGV[0]
rest = ARGV[1..-1] || []
cmd_args, password, solid, recovery, threads = parse_options(rest)

case cmd
when 'create'
  if cmd_args.length < 2
    puts "Usage: create archive.rar file1 file2 ..."
    exit 1
  end
  archive = cmd_args[0]
  files = cmd_args[1..-1]
  create_archive(archive, files, password: password, solid: solid, recovery: recovery, threads: threads)
when 'extract'
  if cmd_args.length < 1
    puts "Usage: extract archive.rar [output_dir]"
    exit 1
  end
  archive = cmd_args[0]
  output_dir = cmd_args[1] || '.'
  extract_archive(archive, output_dir)
when 'list'
  if cmd_args.length < 1
    puts "Usage: list archive.rar"
    exit 1
  end
  list_archive(cmd_args[0])
when 'add'
  if cmd_args.length < 2
    puts "Usage: add archive.rar file1 file2 ..."
    exit 1
  end
  archive = cmd_args[0]
  files = cmd_args[1..-1]
  add_files(archive, files)
when 'delete'
  if cmd_args.length < 2
    puts "Usage: delete archive.rar file1 file2 ..."
    exit 1
  end
  archive = cmd_args[0]
  files = cmd_args[1..-1]
  delete_files(archive, files)
when 'info'
  if cmd_args.length < 1
    puts "Usage: info archive.rar"
    exit 1
  end
  archive_info(cmd_args[0])
else
  puts "Unknown command: #{cmd}"
end
