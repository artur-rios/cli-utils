#!/usr/bin/env bash
set -euo pipefail

TARGET_PATH="${1:-}"

get_repo_root() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  dirname "$script_dir"
}

if [[ -z "$TARGET_PATH" ]]; then
  TARGET_PATH="$(get_repo_root)"
fi

if [[ ! -d "$TARGET_PATH" ]]; then
  echo "Target path does not exist: $TARGET_PATH" >&2
  exit 1
fi

TARGET_PATH="$(cd "$TARGET_PATH" && pwd)"
PROFILE_FILE="$HOME/.bashrc"

# Ensure PATH line exists and is idempotent
if grep -q "export PATH=\"$TARGET_PATH\"" "$PROFILE_FILE" 2>/dev/null; then
  echo "Profile already contains path: $TARGET_PATH"
else
  echo "export PATH=\"$TARGET_PATH:\$PATH\"" >> "$PROFILE_FILE"
  echo "Added to PATH in $PROFILE_FILE: $TARGET_PATH"
  echo "Run: source \"$PROFILE_FILE\" or restart your shell"
fi
