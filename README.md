# CLI Utils

A small CLI toolkit, providing:

- `init-proj`: Create a new folder with the exact structure and files from [project-template](https://github.com/artur-rios/project-template). The template is fetched from GitHub at runtime (via `git clone` or ZIP download), so no local `project-template` folder is required.
- `ktype`: Types commands into a new `cmd` window at intervals.

## Setup

Add the project folder to your system PATH so you can call the tools from anywhere.

### Windows

- Option 1: Current user (no admin)

 1. Open Start, search "Environment Variables" → "Edit environment variables for your account".
 2. Under "User variables", select `Path` → Edit → New.
 3. Add the absolute path to the repo folder, e.g. `C:\Repositories\cli-utils`.
 4. Save and restart terminals.

- Option 2: All users (admin)

 1. Open "Edit the system environment variables" → Environment Variables.
 2. Under "System variables", edit `Path` → New.
 3. Add the repository path, for example `C:\Repositories\cli-utils`.
 4. Save and restart terminals.

### Linux (and WSL)

Add a symlink into a directory already on PATH, typically `/usr/local/bin`:

```bash
sudo ln -s /path/to/your/clone/utils /usr/local/bin/utils
```

Or add the repo directory to PATH in your shell profile:

```bash
echo 'export PATH="/path/to/your/clone:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### One-line setup scripts

Run these scripts to automatically add this repo to your PATH:

- Windows (user PATH):

```powershell
# From repo root
pwsh setup/add-to-path.ps1

# Or specify a path explicitly
pwsh setup/add-to-path.ps1 "D:\Repositories\cli-utils"
```

- Linux/WSL (bash):

```bash
# From repo root
bash setup/add-to-path.sh
# Or specify a path explicitly
bash setup/add-to-path.sh /mnt/d/Repositories/cli-utils
```

## Install PowerShell

These commands dispatch to PowerShell scripts. Install PowerShell if needed.

### On Windows

- Winget (recommended):

```powershell
winget install --id Microsoft.PowerShell --source winget
```

- Manual download:
  - Visit <https://github.com/PowerShell/PowerShell/releases> and install the latest `.msi`.

After install, `pwsh` should be available. If not, use `powershell`.

### Linux (Ubuntu/Debian example)

- Microsoft apt repository:

```bash
sudo apt-get update
sudo apt-get install -y wget apt-transport-https software-properties-common
wget -q https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y powershell
```

- Snap (many distros):

```bash
sudo snap install powershell --classic
```

Run PowerShell:

```bash
pwsh
```

Notes:

- On WSL, installing PowerShell inside the Linux distro is recommended for using `utils`.
- `utils` prefers `pwsh` and falls back to `powershell`.

## Usage

After adding the project to PATH (see Setup), you can call the commands directly.

### Windows quickstart

PowerShell (recommended):

```powershell
# From repo root without PATH: use the Windows dispatcher explicitly
Push-Location d:\Repositories\cli-utils
.\utils.cmd list
.\utils.cmd test-init-proj
.\utils.cmd init-proj MyNewProject
Pop-Location

# With PATH set to include the repo
utils.cmd list
utils.cmd test-init-proj
utils.cmd init-proj MyNewProject

# If `utils` (bash shim) resolves instead of `utils.cmd`, prefer `utils.cmd`
Get-Command utils    # Shows which entry is being called
```

CMD:

```cmd
utils.cmd list
utils.cmd test-init-proj
utils.cmd init-proj MyNewProject
```

Bash on Windows (Git Bash/WSL) is supported via `utils` but may require LF line endings. If you see `/usr/bin/env: 'bash\r': No such file or directory`, convert line endings to LF or use `utils.cmd`.

### init-proj

- CMD:

```cmd
utils init-proj MyNewProject
utils init-proj "D:\Projects\MyNewProject"
```

- PowerShell:

```powershell
utils init-proj MyNewProject
utils init-proj "D:\Projects\MyNewProject"
```

- Bash (Git Bash/WSL):

```bash
utils init-proj MyNewProject
utils init-proj /mnt/d/Projects/MyNewProject
```

Creates the destination folder populated with the exact contents of `project-template`, fetched from GitHub (excluding the `.git` folder).

### ktype

- CMD:

```cmd
utils ktype 5
```

- PowerShell:

```powershell
utils ktype 5
```

- Bash (Git Bash/WSL):

```bash
utils ktype 5
```

Runs a new `cmd` window and types `echo Hello World <n>` every interval.

### Discoverability

List available commands and tests:

```powershell
utils.cmd list
```

## Tests

You can run tests via the entrypoints once PATH is set:

- CMD:

```cmd
utils test-init-proj
utils test-ktype
```

- PowerShell:

```powershell
utils test-init-proj
utils test-ktype
```

- Bash (Git Bash/WSL):

```bash
utils test-init-proj
utils test-ktype
```

Notes:

- `test-init-proj` creates a temp project via the `tests/test-init-proj.ps1` script, validates it, and cleans up.
- `test-ktype` is a smoke test via `tests/test-ktype.ps1` that starts the script briefly and stops it.

## Contributing

The GitHub repository is a read-only mirror for the real, open-source code of cli-utils. Its home is Forgejo, at
https://git.techcraftsmen.net/artur-rios/cli-utils. If you want to contribute, e-mail me at arturdev@duck.com.

## Legal Details

This project is licensed under the [Artur Rios Attribution License](./LICENSE). It is free and open source: you may view, use, fork, modify, and extend it, provided you credit the author, Artur Rios, with a link to [artur-rios.tech](https://artur-rios.tech) or [github.com/artur-rios](https://github.com/artur-rios).
