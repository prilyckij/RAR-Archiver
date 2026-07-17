// Archiver.java
import java.io.*;
import java.util.*;

public class Archiver {
    static boolean checkRarInstalled() {
        try {
            Process p = Runtime.getRuntime().exec(new String[]{"rar", "--version"});
            p.waitFor();
            return true;
        } catch (Exception e) {
            System.err.println("Error: 'rar' command not found. Please install WinRAR or RAR tools.");
            return false;
        }
    }

    static boolean runRarCommand(String[] args) {
        try {
            ProcessBuilder pb = new ProcessBuilder(args);
            pb.redirectErrorStream(true);
            Process p = pb.start();
            BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream()));
            String line;
            while ((line = br.readLine()) != null) {
                System.out.println(line);
            }
            return p.waitFor() == 0;
        } catch (Exception e) {
            System.err.println("RAR error: " + e.getMessage());
            return false;
        }
    }

    static boolean createArchive(String archive, List<String> files, String password, boolean solid, boolean recovery, int threads) {
        List<String> args = new ArrayList<>();
        args.add("rar");
        args.add("a");
        if (password != null && !password.isEmpty()) args.add("-hp" + password);
        if (solid) args.add("-s");
        if (recovery) args.add("-rr");
        if (threads > 0) args.add("-mt" + threads);
        args.add(archive);
        args.addAll(files);
        return runRarCommand(args.toArray(new String[0]));
    }

    static boolean extractArchive(String archive, String outputDir) {
        List<String> args = new ArrayList<>();
        args.add("rar");
        args.add("x");
        args.add(archive);
        if (outputDir != null && !outputDir.equals(".")) args.add(outputDir);
        return runRarCommand(args.toArray(new String[0]));
    }

    static boolean listArchive(String archive) {
        return runRarCommand(new String[]{"rar", "l", archive});
    }

    static boolean addFiles(String archive, List<String> files) {
        List<String> args = new ArrayList<>();
        args.add("rar");
        args.add("a");
        args.add(archive);
        args.addAll(files);
        return runRarCommand(args.toArray(new String[0]));
    }

    static boolean deleteFiles(String archive, List<String> files) {
        List<String> args = new ArrayList<>();
        args.add("rar");
        args.add("d");
        args.add(archive);
        args.addAll(files);
        return runRarCommand(args.toArray(new String[0]));
    }

    static boolean archiveInfo(String archive) {
        return runRarCommand(new String[]{"rar", "v", archive});
    }

    static class ParseResult {
        List<String> args;
        String password;
        boolean solid, recovery;
        int threads;
        ParseResult(List<String> a, String p, boolean s, boolean r, int t) {
            args = a; password = p; solid = s; recovery = r; threads = t;
        }
    }

    static ParseResult parseOptions(String[] args) {
        List<String> result = new ArrayList<>();
        String password = "";
        boolean solid = false, recovery = false;
        int threads = 0;
        for (int i = 0; i < args.length; i++) {
            if (args[i].equals("--password") && i + 1 < args.length) {
                password = args[++i];
            } else if (args[i].equals("--solid")) {
                solid = true;
            } else if (args[i].equals("--recovery")) {
                recovery = true;
            } else if (args[i].equals("--threads") && i + 1 < args.length) {
                threads = Integer.parseInt(args[++i]);
            } else {
                result.add(args[i]);
            }
        }
        return new ParseResult(result, password, solid, recovery, threads);
    }

    public static void main(String[] args) throws Exception {
        if (args.length < 1) {
            System.out.println("Usage: java Archiver <command> [options]\n" +
                               "Commands:\n" +
                               "  create archive.rar file1 file2 ...\n" +
                               "  extract archive.rar [output_dir]\n" +
                               "  list archive.rar\n" +
                               "  add archive.rar file1 file2 ...\n" +
                               "  delete archive.rar file1 file2 ...\n" +
                               "  info archive.rar\n" +
                               "Options:\n" +
                               "  --password PWD   Protect with password\n" +
                               "  --solid          Use solid archiving\n" +
                               "  --recovery       Add recovery records\n" +
                               "  --threads N      Number of threads");
            return;
        }

        if (!checkRarInstalled()) return;

        String cmd = args[0];
        String[] rest = Arrays.copyOfRange(args, 1, args.length);
        ParseResult parsed = parseOptions(rest);

        switch (cmd.toLowerCase()) {
            case "create":
                if (parsed.args.size() < 2) {
                    System.out.println("Usage: create archive.rar file1 file2 ...");
                    return;
                }
                String archive = parsed.args.get(0);
                List<String> files = parsed.args.subList(1, parsed.args.size());
                createArchive(archive, files, parsed.password, parsed.solid, parsed.recovery, parsed.threads);
                break;
            case "extract":
                if (parsed.args.size() < 1) {
                    System.out.println("Usage: extract archive.rar [output_dir]");
                    return;
                }
                String outDir = parsed.args.size() > 1 ? parsed.args.get(1) : ".";
                extractArchive(parsed.args.get(0), outDir);
                break;
            case "list":
                if (parsed.args.size() < 1) { System.out.println("Usage: list archive.rar"); return; }
                listArchive(parsed.args.get(0));
                break;
            case "add":
                if (parsed.args.size() < 2) { System.out.println("Usage: add archive.rar file1 file2 ..."); return; }
                addFiles(parsed.args.get(0), parsed.args.subList(1, parsed.args.size()));
                break;
            case "delete":
                if (parsed.args.size() < 2) { System.out.println("Usage: delete archive.rar file1 file2 ..."); return; }
                deleteFiles(parsed.args.get(0), parsed.args.subList(1, parsed.args.size()));
                break;
            case "info":
                if (parsed.args.size() < 1) { System.out.println("Usage: info archive.rar"); return; }
                archiveInfo(parsed.args.get(0));
                break;
            default:
                System.out.println("Unknown command: " + cmd);
        }
    }
}
