// gdc (zshrc) opens a set of diffs here: all of them in one multi-file diff editor tab, with
// Source Control in the sidebar. The VS Code command line can only open one diff at a time and
// can't run commands, so gdc drops a list of files into ~/.cache/gdc/pending and opens the
// repo's window. This extension runs in every window and checks that folder every second (a
// readdir of a near-empty folder, which is cheaper and sturdier than a file watcher); the window
// whose folder is the list's repo claims the list and opens it. A window that's just opening
// starts checking once it's ready, so a list never arrives too early.
//
// It also lists the files in a "gdc" section of the Source Control sidebar, with Source Control's
// A/M/D letters, since Source Control itself only lists uncommitted changes and so shows nothing
// for a branch's commits. Clicking a file opens its diff; the section's button reopens them all.
//
// A list is NUL-separated: the title, the repo's path, then three fields per file: the file's
// path (its label), the old side and the new side. An empty side means added or deleted.

const fs = require('fs');
const os = require('os');
const path = require('path');
const vscode = require('vscode');

const pending = path.join(os.homedir(), '.cache', 'gdc', 'pending');
const maxAge = 2 * 60 * 1000; // a list nobody claimed by then is stale

function realpath(p) {
  try {
    return fs.realpathSync(p);
  } catch {
    return p;
  }
}

function windowRoots() {
  return (vscode.workspace.workspaceFolders || []).map((folder) => realpath(folder.uri.fsPath));
}

const statuses = {
  A: { tooltip: 'Added', color: 'gitDecoration.addedResourceForeground' },
  M: { tooltip: 'Modified', color: 'gitDecoration.modifiedResourceForeground' },
  D: { tooltip: 'Deleted', color: 'gitDecoration.deletedResourceForeground' },
};
const uri = (p) => (p ? vscode.Uri.file(p) : undefined);

// The diff this window last opened, and the sidebar section that lists its files
let current = { title: '', files: [] };
const changed = new vscode.EventEmitter();
const fileList = {
  onDidChangeTreeData: changed.event,
  getChildren: () => current.files,
  getTreeItem(file) {
    // the query marks it as one of gdc's, for the A/M/D letter below; the label, file icon and
    // folder (description: true) come from the path
    const item = new vscode.TreeItem(vscode.Uri.file(file.path).with({ query: `gdc=${file.status}` }));
    item.iconPath = vscode.ThemeIcon.File;
    item.description = true;
    item.command = { command: 'gdc.openFile', title: 'Open Diff', arguments: [file] };
    return item;
  },
};

// Source Control's colored letter for each file in the list, and nothing for any other file
const letters = {
  provideFileDecoration(resource) {
    const status = statuses[new URLSearchParams(resource.query).get('gdc')];
    if (!status) return undefined;
    return new vscode.FileDecoration(status.tooltip[0], status.tooltip, new vscode.ThemeColor(status.color));
  },
};

async function openAll() {
  const resources = current.files.map((file) => [vscode.Uri.file(file.path), uri(file.old), uri(file.new)]);
  await vscode.commands.executeCommand('vscode.changes', current.title, resources);
}

// One file's diff. vscode.diff needs both sides, so an added or deleted file opens on its own.
async function openFile(file) {
  if (file.old && file.new) {
    const title = `${path.basename(file.path)} (${current.title})`;
    await vscode.commands.executeCommand('vscode.diff', uri(file.old), uri(file.new), title);
  } else {
    await vscode.commands.executeCommand('vscode.open', uri(file.old || file.new));
  }
}

async function open(title, fields) {
  const files = [];
  for (let i = 0; i + 2 < fields.length; i += 3) {
    const [file, old, nu] = fields.slice(i, i + 3);
    files.push({ path: file, old, new: nu, status: !old ? 'A' : !nu ? 'D' : 'M' });
  }
  current = { title, files };
  changed.fire();
  await vscode.commands.executeCommand('setContext', 'gdc.hasFiles', true);
  await vscode.commands.executeCommand('workbench.view.scm');
  try {
    await vscode.commands.executeCommand('gdc.files.focus');
  } catch {
    // the section was hidden until now, and may not be ready to focus yet; it shows either way
  }
  await openAll();
}

let checking = false;

async function claimPending() {
  if (checking) return;
  checking = true;
  try {
    await claimEach();
  } finally {
    checking = false;
  }
}

async function claimEach() {
  let names;
  try {
    names = fs.readdirSync(pending).filter((name) => name.endsWith('.list'));
  } catch {
    return;
  }
  const roots = windowRoots();
  for (const name of names) {
    const file = path.join(pending, name);
    let text, age;
    try {
      text = fs.readFileSync(file, 'utf8');
      age = Date.now() - fs.statSync(file).mtimeMs;
    } catch {
      continue; // another window claimed it first
    }
    if (age > maxAge) {
      fs.rmSync(file, { force: true });
      continue;
    }
    const [title, root, ...fields] = text.split('\0');
    if (!roots.includes(realpath(root))) continue;
    // Claim it by moving it, which only one window can do, in case two have this repo open.
    const claimed = `${file}.${process.pid}`;
    try {
      fs.renameSync(file, claimed);
    } catch {
      continue;
    }
    fs.rmSync(claimed, { force: true });
    try {
      await open(title, fields);
    } catch (error) {
      vscode.window.showErrorMessage(`gdc: ${error.message}`);
    }
  }
}

function activate(context) {
  const view = vscode.window.createTreeView('gdc.files', { treeDataProvider: fileList });
  changed.event(() => {
    view.title = current.title;
    view.description = `${current.files.length} files`;
  });
  context.subscriptions.push(
    view,
    vscode.window.registerFileDecorationProvider(letters),
    vscode.commands.registerCommand('gdc.openAll', openAll),
    vscode.commands.registerCommand('gdc.openFile', openFile)
  );
  const timer = setInterval(claimPending, 1000);
  context.subscriptions.push({ dispose: () => clearInterval(timer) });
  claimPending();
}

module.exports = { activate };
