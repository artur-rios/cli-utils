$ErrorActionPreference = 'Stop'

function New-TempPath {
    $base = Join-Path ([System.IO.Path]::GetTempPath()) ("cli-utils-test-" + [System.Guid]::NewGuid().ToString())
    return $base
}

function Assert($condition, [string]$message) {
    if (-not $condition) { throw "TEST FAIL: $message" }
}

Write-Host "[INIT] test-init-proj starting"

$dest = New-TempPath

Write-Host "[INFO] Running init-proj to: $dest"

# Invoke init-proj command script directly
$cmdScript = Join-Path (Split-Path -Parent $PSScriptRoot) 'commands/init-proj.ps1'
& $cmdScript -NameOrPath $dest

Write-Host "[STEP] 1/2 Verifying destination exists and is not empty"
Assert (Test-Path $dest) "Destination not created: $dest"
$items = Get-ChildItem -LiteralPath $dest -Force
Assert ($items.Count -gt 0) "Destination is empty: $dest"

Write-Host "[STEP] 2/2 Cleaning up test artifacts"
try { Remove-Item -LiteralPath $dest -Recurse -Force -ErrorAction SilentlyContinue } catch {}

Write-Host "[INFO] test-init-proj passed"
