#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
prefix="${PREFIX:-$HOME/.local}"
quickshell_dir="${QUICKSHELL_DIR:-}"

usage() {
    cat <<'USAGE'
Usage: ./install.sh [options]

Options:
  --prefix DIR             Installation prefix (default: $HOME/.local)
  --quickshell-dir DIR    Also install the optional Quickshell overlay there
  --help                   Show this help

The installer never installs Whisper, a model, or system packages.
USAGE
}

while (($#)); do
    case "$1" in
        --prefix)
            (($# >= 2)) || { echo "--prefix requires a directory" >&2; exit 2; }
            prefix=$2
            shift 2
            ;;
        --quickshell-dir)
            (($# >= 2)) || { echo "--quickshell-dir requires a directory" >&2; exit 2; }
            quickshell_dir=$2
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

bin_dir="$prefix/bin"
install -d "$bin_dir"
install -m 0755 "$repo_dir/bin/dictate-toggle" "$bin_dir/dictate-toggle"
install -m 0755 "$repo_dir/bin/dictate-overlay" "$bin_dir/dictate-overlay"

if [[ -n "$quickshell_dir" ]]; then
    install -d "$quickshell_dir"
    install -m 0644 "$repo_dir/ui/DictationOverlay.qml" "$quickshell_dir/DictationOverlay.qml"
fi

cat <<EOF
Installed dictation scripts in:
  $bin_dir/dictate-toggle
  $bin_dir/dictate-overlay

The main script types the transcription directly with wtype. It does not use the clipboard.
EOF

if [[ -n "$quickshell_dir" ]]; then
    cat <<EOF
Installed optional overlay in:
  $quickshell_dir/DictationOverlay.qml

Add this component once inside the root object of your Quickshell shell.qml:
  DictationOverlay {}
EOF
else
    cat <<'EOF'
To install the optional Quickshell overlay, run again with:
  ./install.sh --quickshell-dir "$HOME/.config/quickshell/ii"

Then add this component once inside the root object of shell.qml:
  DictationOverlay {}
EOF
fi

cat <<EOF
For a Hyprland keybind, see:
  $repo_dir/integrations/hyprland-keybind.lua

See README.md for dependencies, Whisper setup, environment variables, and troubleshooting.
EOF
