// archiver.js
const { exec } = require('child_process');
const fs = require('fs');

function checkRarInstalled() {
    return new Promise((resolve) => {
        exec('rar --version', (error) => {
            if (error) {
                console.error("Error: 'rar' command not found. Please install WinRAR or RAR tools.");
                resolve(false);
            } else {
                resolve(true);
            }
        });
    });
}

function runRarCommand(args) {
    return new Promise((resolve) => {
        const cmd = `rar ${args.join(' ')}`;
        exec(cmd, (error, stdout, stderr) => {
            if (error) {
                console.error('RAR error:', stderr || error.message);
                resolve(false);
            } else {
                console.log(stdout);
                resolve(true);
            }
        });
    });
}

async function createArchive(archive, files, password, solid, recovery, threads) {
    const args = ['a'];
    if (password) args.push(`-hp${password}`);
    if (solid) args.push('-s');
    if (recovery) args.push('-rr');
    if (threads) args.push(`-mt${threads}`);
    args.push(archive);
    args.push(...files);
    return await runRarCommand(args);
}

async function extractArchive(archive, outputDir = '.') {
    const args = ['x', archive];
    if (outputDir !== '.') args.push(outputDir);
    return await runRarCommand(args);
}

async function listArchive(archive) {
    return await runRarCommand(['l', archive]);
}

async function addFiles(archive, files) {
    return await runRarCommand(['a', archive, ...files]);
}

async function deleteFiles(archive, files) {
    return await runRarCommand(['d', archive, ...files]);
}

async function archiveInfo(archive) {
    return await runRarCommand(['v', archive]);
}

function parseOptions(args) {
    const result = [];
    let password = '';
    let solid = false;
    let recovery = false;
    let threads = 0;
    for (let i = 0; i < args.length; i++) {
        if (args[i] === '--password' && i+1 < args.length) {
            password = args[i+1];
            i++;
        } else if (args[i] === '--solid') {
            solid = true;
        } else if (args[i] === '--recovery') {
            recovery = true;
        } else if (args[i] === '--threads' && i+1 < args.length) {
            threads = parseInt(args[i+1]);
            i++;
        } else {
            result.push(args[i]);
        }
    }
    return { args: result, password, solid, recovery, threads };
}

async function main() {
    const args = process.argv.slice(2);
    if (args.length < 1) {
        console.log(`Usage: node archiver.js <command> [options]
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
  --threads N      Number of threads`);
        process.exit(1);
    }

    if (!(await checkRarInstalled())) {
        process.exit(1);
    }

    const cmd = args[0];
    const rest = args.slice(1);
    const { args: cmdArgs, password, solid, recovery, threads } = parseOptions(rest);

    switch (cmd) {
        case 'create':
            if (cmdArgs.length < 2) {
                console.log('Usage: create archive.rar file1 file2 ...');
                return;
            }
            const archive = cmdArgs[0];
            const files = cmdArgs.slice(1);
            await createArchive(archive, files, password, solid, recovery, threads);
            break;
        case 'extract':
            if (cmdArgs.length < 1) {
                console.log('Usage: extract archive.rar [output_dir]');
                return;
            }
            await extractArchive(cmdArgs[0], cmdArgs[1] || '.');
            break;
        case 'list':
            if (cmdArgs.length < 1) {
                console.log('Usage: list archive.rar');
                return;
            }
            await listArchive(cmdArgs[0]);
            break;
        case 'add':
            if (cmdArgs.length < 2) {
                console.log('Usage: add archive.rar file1 file2 ...');
                return;
            }
            await addFiles(cmdArgs[0], cmdArgs.slice(1));
            break;
        case 'delete':
            if (cmdArgs.length < 2) {
                console.log('Usage: delete archive.rar file1 file2 ...');
                return;
            }
            await deleteFiles(cmdArgs[0], cmdArgs.slice(1));
            break;
        case 'info':
            if (cmdArgs.length < 1) {
                console.log('Usage: info archive.rar');
                return;
            }
            await archiveInfo(cmdArgs[0]);
            break;
        default:
            console.log(`Unknown command: ${cmd}`);
    }
}

main().catch(console.error);
