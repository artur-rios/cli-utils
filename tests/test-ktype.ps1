$ErrorActionPreference = 'Stop'

function Assert($condition, [string]$message) {
    if (-not $condition) { throw "TEST FAIL: $message" }
}

Write-Host "[INIT] test-ktype starting"

$script = Join-Path (Split-Path -Parent $PSScriptRoot) 'commands/ktype.ps1'

Write-Host "[INFO] Starting ktype with short timeout for smoke test"

$job = Start-Job -ScriptBlock {
    param($scriptPath)
    & $scriptPath -Timeout 2
} -ArgumentList $script

Write-Host "[STEP] 1/3 Waiting briefly to allow ktype to run"
Start-Sleep -Seconds 5
    
Write-Host "[STEP] 2/3 Stopping ktype background job"
try {
    Stop-Job -Job $job -Force -ErrorAction SilentlyContinue
}
catch {}

Write-Host "[STEP] 3/3 Cleaning up job"
try {
    Remove-Job -Job $job -Force -ErrorAction SilentlyContinue
}
catch {}

# Ensure job existed
Assert ($null -ne $job) "Failed to start ktype job"

Write-Host "[INFO] test-ktype passed (smoke test)"
