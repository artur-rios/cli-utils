#!/bin/sh
# The `build` check: there is nothing to compile, so it checks what can be checked of the scripts on Linux.
#   1. Syntax: `bash -n` for the Bash scripts (utils, setup/add-to-path.sh), PowerShell's own parser for every
#      .ps1 (commands/, setup/, tests/, ci/).
#   2. The tests that run on Linux, through the Bash dispatcher as the README runs them: `utils list`, and
#      `utils test-init-proj`, which runs init-proj into a temporary folder (it clones project-template from GitHub)
#      and checks the result.
# Left out: test-ktype, which is Windows only (ktype starts cmd.exe and types into it through WScript.Shell), and
# utils.cmd (a batch file: nothing on Linux parses it).
#
# yggdrasil.yml runs it in the pinned .NET SDK image (Ubuntu, with bash, git and PowerShell 7) from the
# repository's root; by hand, from that root:
#   docker run --rm -v "$PWD:/src" -w /src <image> sh ci/build.sh
set -eu

# The repository's root, wherever this is run from.
cd "$(dirname "$0")/.."

echo "== bash -n"
for script in utils setup/add-to-path.sh; do
  bash -n "$script"
  echo "$script: ok"
done

echo "== PowerShell parser"
# shellcheck disable=SC2016 # PowerShell code: the shell must not expand it.
pwsh -NoProfile -NonInteractive -Command '
  $failed = 0
  foreach ($file in Get-ChildItem -Path commands, setup, tests, ci -Recurse -Filter *.ps1) {
    $errors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$null, [ref]$errors)
    foreach ($e in $errors) {
      Write-Output "$($file.FullName):$($e.Extent.StartLineNumber): $($e.Message)"
      $failed++
    }
    if (-not $errors) { Write-Output "$(Resolve-Path -Relative $file.FullName): ok" }
  }
  if ($failed) { exit 1 }
'

echo "== utils list"
bash utils list

echo "== utils test-init-proj"
bash utils test-init-proj
