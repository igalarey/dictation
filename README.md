# Dictation for Wayland

Local dictation for Linux on Wayland. It records audio, transcribes it with
[whisper.cpp](https://github.com/ggerganov/whisper.cpp), and types the result into the
focused window.

The transcription is typed directly with `wtype`. **It is not copied to the clipboard and
is not pasted with Ctrl+V.** Temporary audio and transcription files stay on the local
machine and are removed when processing finishes.

## Requirements

- Linux with Wayland.
- `pw-record`, usually provided by PipeWire.
- `wtype`.
- `python3`.
- `notify-send`, usually provided by `libnotify`.
- A Vulkan-enabled `whisper.cpp` executable.
- A compatible whisper.cpp model.
- Optional: Quickshell for the visual status indicator.
- Optional: Hyprland with this repository's Lua integration for the `Super+D` shortcut.

On Arch Linux, the usual dependencies are:

```bash
sudo pacman -S pipewire wtype python libnotify vulkan-loader
```

The project does not install system packages, the Whisper executable, or models.

## Installation

Clone the repository and run the installer:

```bash
git clone https://github.com/igalarey/dictation.git "$HOME/Archivos/vscode/dictation"
cd "$HOME/Archivos/vscode/dictation"
./install.sh --prefix "$HOME/.local"
```

To also install the Quickshell indicator into the `ii` configuration:

```bash
./install.sh \
  --prefix "$HOME/.local" \
  --quickshell-dir "$HOME/.config/quickshell/ii"
```

The installer places these files in `~/.local/bin`:

- `dictate-toggle`: starts or stops recording and runs the transcription.
- `dictate-overlay`: sends state updates to the optional Quickshell indicator.

### Configure Whisper

The executable and model are not included in this repository. This avoids uploading
large binaries and models that may have different distribution terms.

By default, the program looks for:

```text
Executable: ~/.local/bin/whisper-cli-vulkan
Model:     ~/.local/share/whisper/models/ggml-large-v3-turbo-q5_0.bin
```

You can use different paths with environment variables. For example:

```bash
export DICTATE_WHISPER_CLI="$HOME/.local/bin/whisper-cli"
export DICTATE_MODEL="$HOME/.local/share/whisper/models/ggml-base.bin"
```

The executable must accept the whisper.cpp options used by the script: `-m`, `-f`, `-l`,
`-dev`, `-nt`, `-otxt`, `-of`, and `-np`.

### Enable the Quickshell overlay

If you installed `DictationOverlay.qml`, add this component once inside the root object
of `shell.qml`:

```qml
DictationOverlay {}
```

See `integrations/quickshell-shell.qml` for an example. Then reload Quickshell. The
overlay is optional: dictation continues to work without it and uses notifications when
needed.

### Add the Hyprland shortcut

Add the contents of `integrations/hyprland-keybind.lua` to your Lua keybinds file. The
example assigns `Super+D` to dictation and first unbinds the previous shortcut.

Then reload Hyprland.

## Usage

1. Focus the field where you want to type.
2. Press `Super+D` or run `~/.local/bin/dictate-toggle`.
3. Speak while the listening indicator is visible.
4. Press the shortcut again to stop recording.
5. Wait for Whisper to finish. The text is typed directly into the application.

You can use the program with another language:

```bash
DICTATE_LANGUAGE=en ~/.local/bin/dictate-toggle
```

The first invocation starts recording. The second stops recording and transcribes it. If
no voice activity is detected, Whisper is not started.

## Environment variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `DICTATE_MODEL` | `~/.local/share/whisper/models/ggml-large-v3-turbo-q5_0.bin` | Whisper model |
| `DICTATE_WHISPER_CLI` | `~/.local/bin/whisper-cli-vulkan` | Whisper executable |
| `DICTATE_OVERLAY_CALLER` | `~/.local/bin/dictate-overlay` | Overlay client |
| `DICTATE_LANGUAGE` | `es` | Transcription language |
| `DICTATE_WHISPER_DEVICE` | `0` | Whisper Vulkan device |
| `DICTATE_STATE_DIR` | `$XDG_RUNTIME_DIR/dictation` | Temporary WAV, PID, lock, and text files |
| `DICTATE_LOG_DIR` | `~/.local/state/dictation` | Log directory |
| `DICTATE_QUICKSHELL_CONFIG` | `ii` | Configuration used by `qs` |

## Privacy and security

- Transcription runs locally.
- No remote API is used.
- Temporary audio and text files are removed after successful processing or a recoverable
  error.
- Transcribed text is not written to the clipboard.
- The log contains status messages and errors, not the transcribed text by design.
- Do not upload models, recordings, logs, or binaries to the public repository.

## Troubleshooting

### `Whisper Vulkan engine is missing`

Check the executable path:

```bash
ls -l "$HOME/.local/bin/whisper-cli-vulkan"
```

If you use another path, set `DICTATE_WHISPER_CLI`.

### `Whisper model is missing`

Check the configured path and set `DICTATE_MODEL` if necessary.

### Text is not typed

Make sure the destination field keeps focus when transcription finishes and that `wtype`
works with your Wayland compositor. Some protected fields or applications that block
virtual keyboards do not accept this input.

### The overlay does not appear

The overlay is optional. Check that `qs` is installed, that `shell.qml` contains
`DictationOverlay {}`, and that `DICTATE_QUICKSHELL_CONFIG` matches your configuration
name.

### View the log

```bash
tail -f "$HOME/.local/state/dictation/dictation.log"
```

## Uninstallation

```bash
rm -f "$HOME/.local/bin/dictate-toggle" "$HOME/.local/bin/dictate-overlay"
rm -f "$HOME/.config/quickshell/ii/DictationOverlay.qml"
```

Also remove `DictationOverlay {}` from `shell.qml` and the shortcut block from your
Hyprland configuration.

## Project structure

```text
bin/                          Executable scripts
ui/                           Quickshell overlay
integrations/                 Hyprland and Quickshell examples
tests/                        Static checks
install.sh                    Local installer
```

## License

This project is distributed under the [MIT License](LICENSE). It does not include models,
binaries, or credentials.
