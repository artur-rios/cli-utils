# The PowerShell half of ci/lint.sh: unpacks the PSScriptAnalyzer package ci/lint.sh fetched and checked, runs it
# over each path given after -Package (recursively) with the repository's PSScriptAnalyzerSettings.psd1, prints
# every finding, and exits 1 when there is any. Run from the repository's root. By hand, with PSScriptAnalyzer
# installed, the same check for one folder is:
#   Invoke-ScriptAnalyzer -Path commands -Recurse -Settings ./PSScriptAnalyzerSettings.psd1
param(
    [Parameter(Mandatory)] [string] $Package,
    [Parameter(Mandatory, ValueFromRemainingArguments)] [string[]] $Path
)

$ErrorActionPreference = 'Stop'

# A .nupkg is a zip with the module's files at its root.
$module = Join-Path ([System.IO.Path]::GetDirectoryName($Package)) 'PSScriptAnalyzer'
Expand-Archive -LiteralPath $Package -DestinationPath $module -Force
Import-Module (Join-Path $module 'PSScriptAnalyzer.psd1')
Write-Output "PSScriptAnalyzer $((Get-Module PSScriptAnalyzer).Version)"

$findings = @(foreach ($p in $Path) {
        Invoke-ScriptAnalyzer -Path $p -Recurse -Settings (Join-Path $PWD 'PSScriptAnalyzerSettings.psd1')
    })
if ($findings.Count -gt 0) {
    $findings | Format-Table -AutoSize -Wrap ScriptName, Line, Severity, RuleName, Message | Out-String -Width 200 | Write-Output
    Write-Error "ci/psscriptanalyzer.ps1: $($findings.Count) finding(s)" -ErrorAction Continue
    exit 1
}
Write-Output 'ci/psscriptanalyzer.ps1: no findings'
