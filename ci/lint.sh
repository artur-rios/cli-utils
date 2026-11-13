#!/bin/sh
# The `lint` check: ShellCheck over the Bash scripts (utils, setup/add-to-path.sh and ci/'s own) and PSScriptAnalyzer
# over the PowerShell ones (commands/, setup/, tests/, ci/), with the rules PSScriptAnalyzerSettings.psd1 sets
# (ci/psscriptanalyzer.ps1 runs it). utils.cmd is not checked: no linter for batch files runs on Linux.
#
# Both tools are pinned: each release file is fetched from GitHub, checked against its pinned sha256 and used from
# a temporary directory, so nothing is installed into the image. Renovate follows the versions (the comments above
# them), not the checksums: when it moves one, copy the new file's sha256 from its release page into this file.
#
# yggdrasil.yml runs it in the pinned .NET SDK image (Ubuntu, with curl and PowerShell 7) from the repository's
# root; by hand, from that root:
#   docker run --rm -v "$PWD:/src" -w /src <image> sh ci/lint.sh
set -eu

# The repository's root, wherever this is run from.
cd "$(dirname "$0")/.."

# renovate: datasource=github-releases depName=koalaman/shellcheck
SHELLCHECK_VERSION=v0.11.0
SHELLCHECK_SHA256_X86_64=b7af85e41cc99489dcc21d66c6d5f3685138f06d34651e6d34b42ec6d54fe6f6
SHELLCHECK_SHA256_AARCH64=68a8133197a50beb8803f8d42f9908d1af1c5540d4bb05fdfca8c1fa47decefc
# renovate: datasource=github-releases depName=PowerShell/PSScriptAnalyzer
PSSCRIPTANALYZER_VERSION=1.25.0
PSSCRIPTANALYZER_SHA256=14e634c828eb98efb9f40b2918ba90f139ed5eccdf663a2a747736d996995d60

tools=$(mktemp -d)
trap 'rm -rf "$tools"' EXIT

# fetch <url> <sha256> <file>: downloads the url to the file and checks it, or fails naming it.
fetch() {
  curl --fail --silent --show-error --location --retry 3 -o "$3" "$1"
  if ! echo "$2  $3" | sha256sum --check --strict --status; then
    echo "ci/lint.sh: $1 does not match its pinned checksum" >&2
    exit 1
  fi
}

case $(uname -m) in
  x86_64) arch=x86_64 sha256=$SHELLCHECK_SHA256_X86_64 ;;
  aarch64 | arm64) arch=aarch64 sha256=$SHELLCHECK_SHA256_AARCH64 ;;
  *) echo "ci/lint.sh: no pinned ShellCheck for $(uname -m)" >&2; exit 1 ;;
esac
fetch "https://github.com/koalaman/shellcheck/releases/download/$SHELLCHECK_VERSION/shellcheck-$SHELLCHECK_VERSION.linux.$arch.tar.gz" \
  "$sha256" "$tools/shellcheck.tar.gz"
tar -xzf "$tools/shellcheck.tar.gz" -C "$tools" --no-same-owner
shellcheck="$tools/shellcheck-$SHELLCHECK_VERSION/shellcheck"
"$shellcheck" --version
# Both tools run, whatever the first finds; the check fails if either does.
status=0
"$shellcheck" utils setup/add-to-path.sh ci/*.sh || status=1

fetch "https://github.com/PowerShell/PSScriptAnalyzer/releases/download/$PSSCRIPTANALYZER_VERSION/PSScriptAnalyzer.$PSSCRIPTANALYZER_VERSION.nupkg" \
  "$PSSCRIPTANALYZER_SHA256" "$tools/PSScriptAnalyzer.nupkg"
pwsh -NoProfile -NonInteractive -File ci/psscriptanalyzer.ps1 -Package "$tools/PSScriptAnalyzer.nupkg" \
  commands setup tests ci || status=1
exit $status
