param(
    [Parameter(Position = 0)]
    [string] $NameOrPath
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($NameOrPath)) {
    # If invoked via -File, PowerShell may place positional args in $args; bind first if present
    if ($args.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace($args[0])) {
        $NameOrPath = $args[0]
    }
}

if ([string]::IsNullOrWhiteSpace($NameOrPath)) {
    Write-Host "[ERROR] Destination name/path is required. Usage: utils init-proj <name-or-path>"
    exit 1
}

# Guard against accidental binding of the script name itself (e.g., 'init-proj')
$scriptBase = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
if ($NameOrPath -eq $scriptBase) {
    Write-Host "[ERROR] Destination name/path is required. Usage: utils init-proj <name-or-path>"
    exit 1
}
Write-Host "[INIT] Starting project creation..."

function Resolve-Destination([string]$inputPath) {
    if ([System.IO.Path]::IsPathRooted($inputPath)) {
        return $inputPath
    }
    return Join-Path -Path (Get-Location) -ChildPath $inputPath
}

$dest = Resolve-Destination -inputPath $NameOrPath

if (Test-Path $dest) {
    Write-Error "[ERROR] Destination already exists: $dest"
}

Write-Host "[STEP] 1/4 Creating project directory at: $dest"
New-Item -ItemType Directory -Path $dest | Out-Null

function Test-Git {
    try {
        $null = & git --version 2>$null
        return $true
    }
    catch { return $false }
}

function Copy-FromFolder([string]$sourceFolder, [string]$targetFolder) {
    # Copy all items including hidden/system (dotfiles) EXACTLY as in template
    Get-ChildItem -LiteralPath $sourceFolder -Force | ForEach-Object {
        $srcItem = $_.FullName
        $destItem = Join-Path $targetFolder $_.Name
        if ($_.PSIsContainer) {
            Copy-Item -LiteralPath $srcItem -Destination $destItem -Recurse -Force
        }
        else {
            Copy-Item -LiteralPath $srcItem -Destination $destItem -Force
        }
    }
}

$repoUrl = 'https://github.com/artur-rios/project-template'

if (Test-Git) {
    Write-Host "[STEP] 2/4 Fetching template with git clone..."
    $tempDir = New-Item -ItemType Directory -Path (Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString()))
    try {
        Push-Location $tempDir.FullName
        & git clone --depth 1 $repoUrl template | Out-Null
        Pop-Location

        $templateRoot = Join-Path $tempDir.FullName 'template'
        # Copy contents except .git
        Write-Host "[STEP] 3/4 Copying template contents (excluding .git)"
        Get-ChildItem -LiteralPath $templateRoot -Force | Where-Object { $_.Name -ne '.git' } | ForEach-Object {
            $srcItem = $_.FullName
            $destItem = Join-Path $dest $_.Name
            if ($_.PSIsContainer) {
                Copy-Item -LiteralPath $srcItem -Destination $destItem -Recurse -Force
            }
            else {
                Copy-Item -LiteralPath $srcItem -Destination $destItem -Force
            }
        }
    }
    finally {
        Write-Host "[STEP] 4/4 Cleaning up temporary files"
        try { Remove-Item -LiteralPath $tempDir.FullName -Recurse -Force -ErrorAction SilentlyContinue } catch {}
    }
}
else {
    Write-Host "[STEP] 2/4 Fetching template by ZIP download..."
    # Use the default branch archive (main); GitHub also supports /archive/refs/heads/main.zip
    $zipUrl = 'https://github.com/artur-rios/project-template/archive/refs/heads/main.zip'
    $tmpZip = Join-Path ([System.IO.Path]::GetTempPath()) ("project-template-" + [System.Guid]::NewGuid().ToString() + '.zip')
    $extractDir = Join-Path ([System.IO.Path]::GetTempPath()) ("pt-extract-" + [System.Guid]::NewGuid().ToString())

    Invoke-WebRequest -Uri $zipUrl -OutFile $tmpZip -UseBasicParsing
    Expand-Archive -LiteralPath $tmpZip -DestinationPath $extractDir -Force

    # The archive usually expands to project-template-main/
    $expandedRoot = Get-ChildItem -LiteralPath $extractDir | Select-Object -First 1
    if (-not $expandedRoot) { Write-Error '[ERROR] Failed to extract template archive.' }
    Write-Host "[STEP] 3/4 Copying template contents from archive"
    Copy-FromFolder -sourceFolder $expandedRoot.FullName -targetFolder $dest

    # Cleanup
    try {
        Write-Host "[STEP] 4/4 Cleaning up temporary files"
        Remove-Item -LiteralPath $tmpZip -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $extractDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    catch {}
}
Write-Host "[INFO] Project created at: $dest"
Write-Host "[INFO] Done."
