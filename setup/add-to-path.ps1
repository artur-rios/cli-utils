param(
    [Parameter(Position = 0)]
    [string] $TargetPath
)

$ErrorActionPreference = 'Stop'

function Get-RepoRoot {
    $scriptDir = Split-Path -Parent $PSCommandPath
    return Split-Path -Parent $scriptDir
}

if (-not $TargetPath -or [string]::IsNullOrWhiteSpace($TargetPath)) {
    $TargetPath = Get-RepoRoot
}

if (-not (Test-Path -LiteralPath $TargetPath)) {
    Write-Error "Target path does not exist: $TargetPath"
}

$resolved = (Resolve-Path -LiteralPath $TargetPath).Path

# Update current user's PATH
$existing = [Environment]::GetEnvironmentVariable('Path', 'User')
$parts = @()
if ($existing) { $parts = $existing -split ';' }

if ($parts -contains $resolved) {
    Write-Host "Path already contains: $resolved" -ForegroundColor Yellow
}
else {
    $newPath = if ([string]::IsNullOrEmpty($existing)) { $resolved } else { "$existing;$resolved" }
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Host "Added to user PATH: $resolved" -ForegroundColor Green
    Write-Host "Restart terminals to pick up changes." -ForegroundColor Cyan
}

# Offer optional system-wide add with -System switch in future (not implemented to avoid admin prompt)
