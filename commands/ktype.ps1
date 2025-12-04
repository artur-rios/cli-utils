param(
    [Parameter(Position = 0)]
    [string] $Timeout = '20'
)

$ErrorActionPreference = 'Stop'

# Normalize timeout: accept empty/non-numeric and default to 20
try {
    $parsed = [int]::Parse($Timeout)
    if ($parsed -le 0) { $parsed = 20 }
}
catch {
    $parsed = 20
}
$Timeout = $parsed

Write-Host "Starting ktype with timeout: $Timeout seconds" -ForegroundColor Cyan

# Launch a new CMD window
$proc = Start-Process -FilePath cmd.exe -PassThru
Start-Sleep -Seconds 1

# Try to activate the CMD window
$wshell = New-Object -ComObject WScript.Shell
try { [void]$wshell.AppActivate($proc.Id) } catch { }

# Optional initial delay similar to the batch version
Start-Sleep -Seconds 15

$counter = 1
while ($true) {
    Start-Sleep -Seconds $Timeout
    $text = "echo Hello World $counter"
    [void]$wshell.SendKeys($text + "{ENTER}")
    $counter++
}
