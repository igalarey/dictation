#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)

bash -n "$repo_dir/install.sh"
bash -n "$repo_dir/bin/dictate-toggle"
bash -n "$repo_dir/bin/dictate-overlay"

test ! -e "$repo_dir/bin/whisper-cli-vulkan"
! grep -q 'wl-copy' "$repo_dir/bin/dictate-toggle"
grep -q 'printf.*wtype -' "$repo_dir/bin/dictate-toggle"
grep -q 'target: "dictationOverlay"' "$repo_dir/ui/DictationOverlay.qml"
grep -q 'DictationOverlay {}' "$repo_dir/integrations/quickshell-shell.qml"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

"$repo_dir/install.sh" --prefix "$tmp_dir/local" >/dev/null
test -x "$tmp_dir/local/bin/dictate-toggle"
test -x "$tmp_dir/local/bin/dictate-overlay"
test ! -e "$tmp_dir/local/bin/DictationOverlay.qml"

"$repo_dir/install.sh" \
    --prefix "$tmp_dir/local-with-overlay" \
    --quickshell-dir "$tmp_dir/quickshell" >/dev/null
test -f "$tmp_dir/quickshell/DictationOverlay.qml"

echo "static checks: OK"
