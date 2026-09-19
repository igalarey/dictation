-- Add this to a Hyprland keybind file managed with hyprland Lua.
-- Adjust the key if Super+D is already used by your setup.

local home = os.getenv("HOME")

hl.unbind("SUPER + D")
hl.bind(
    "SUPER + D",
    hl.dsp.exec_cmd(home .. "/.local/bin/dictate-toggle"),
    { description = "Voice: Toggle dictation" }
)
