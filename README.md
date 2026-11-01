# vince-hyper

A minimal, fast, productivity-focused **Hyprland (`0.55+` / `0.57+` native Lua)** desktop configuration for **CachyOS / Arch Linux**.

A clean aesthetic with a curated dark theme switcher, paired with classic **i3 / Vim (`H/J/K/L`) dwindle window management** and standard, battle-tested Wayland components (**Waybar**, **Rofi**, **SwayNC**, **Kitty**, **Cliphist**, **Grim/Slurp**).

---

## Philosophy & Design Goals

1. **Zero Bloat / No Gimmicks**: No custom Quickshell/AGS/Astal daemons, no audio visualizer bars, no docks, no anime wallpapers. Just a crisp top panel and fast keyboard-driven workflows.
2. **Standard i3 / Vim Navigation**: `Super + H/J/K/L` always focuses windows (`Left/Down/Up/Right`), `Super + Shift + H/J/K/L` moves windows, and `Super + Ctrl + H/J/K/L` resizes windows.
3. **Unified Curated Theme Switcher**: One script (`theme-switcher`) simultaneously updates **Hyprland borders**, **Waybar**, **Rofi**, **Kitty**, **SwayNC**, **GTK dark/light preference**, and **Hyprpaper** wallpapers across 10 palettes (6 dark + 4 light):
   - **Dark**: **Tokyo Night** *(default)*, **Catppuccin Mocha**, **Gruvbox Dark**, **Nord**, **Rosé Pine**, **Everforest**
   - **Light**: **Catppuccin Latte (Light)**, **Gruvbox Light**, **Rose Pine Dawn (Light)**, **Solarized Light**
4. **Portable & Self-Contained**: No external dotfile managers, symlink farms, or Python virtualenvs required. `apply.sh` deploys everything cleanly and generates the minimal dark gradient wallpapers programmatically.

---

## Repository Structure

```text
vince-hyper/
├── apply.sh                  # Bootstrap & sync script (apply, --packages, --sync-back)
├── README.md                 # User & AI Agent architecture documentation
├── bin/                      # Installed to ~/.local/bin/
│   ├── theme-switcher        # Rofi theme selector + multi-app palette generator
│   ├── screenshot            # grim + slurp + wl-copy screenshot utility
│   ├── clipboard-menu        # cliphist + rofi clipboard manager
│   ├── power-menu            # rofi power menu (lock, suspend, logout, reboot, shutdown)
│   └── keybinds-menu         # Searchable rofi keybinding cheat sheet
└── config/                   # Installed to ~/.config/
    ├── hypr/
    │   ├── hyprland.lua      # Main Hyprland 0.57+ native Lua configuration
    │   ├── theme.lua         # Auto-generated border/accent colors from theme-switcher
    │   ├── hyprpaper.conf    # Auto-generated wallpaper config from theme-switcher
    │   ├── hyprlock.conf     # Clean lockscreen configuration
    │   └── hypridle.conf     # Idle daemon (10m lock, 15m DPMS off)
    ├── waybar/
    │   ├── config.jsonc      # Top panel layout & module definitions
    │   ├── style.css         # Panel styling (imports colors.css)
    │   └── colors.css        # Auto-generated palette variables
    ├── rofi/
    │   ├── config.rasi       # Rofi modes & vim-friendly keybinds (Ctrl+J/K)
    │   ├── theme.rasi        # Launcher layout & styling (imports colors.rasi)
    │   └── colors.rasi       # Auto-generated palette variables
    ├── kitty/
    │   ├── kitty.conf        # Terminal font, padding, tab bar (includes colors.conf)
    │   └── colors.conf       # Auto-generated 16-color terminal palette
    ├── swaync/
    │   ├── config.json       # Notification daemon & control center config
    │   ├── style.css         # Notification styling (imports colors.css)
    │   └── colors.css        # Auto-generated palette variables
    ├── themes/
    │   └── current           # Stores active theme name
    ├── uwsm/
    │   └── env               # Wayland environment variables
    └── mimeapps.list         # Default file manager (Nautilus) & browser associations
```

---

## Quick Start / Installation

### 1. Apply Configurations (Existing System)
```bash
git clone <your-repo-url> ~/src/vince-hyper
cd ~/src/vince-hyper
./apply.sh
```

### 2. Full Setup on a Fresh CachyOS / Arch Machine
```bash
./apply.sh --packages
```
*(Note: Google Chrome is launched via `flatpak run com.google.Chrome` by default. If you use native Chrome or another browser, update `local browser` in `config/hypr/hyprland.lua`.)*

### 3. Saving Local Tweaks Back to the Repo
If you edit files directly in `~/.config/` or `~/.local/bin/` and want to commit them back to this repository:
```bash
./apply.sh --sync-back
git diff
```

---

## Keybindings Reference

| Shortcut | Action |
| :--- | :--- |
| **`Super` (tap & release)** | App Launcher (`rofi -show drun`) |
| **`Super + D`** / **`Super + Space`** | App Launcher (`rofi -show drun`) |
| **`Super + Tab`** / **`Alt + Tab`** | Window Switcher (`rofi -show window`) / Cycle next window |
| **`Super + Return`** | Terminal (`kitty`) |
| **`Super + B`** | Browser (`Google Chrome`) |
| **`Super + E`** | File Manager (`nautilus`) |
| **`Super + H / J / K / L`** *(or Arrows)* | Focus Left / Down / Up / Right |
| **`Super + Shift + H / J / K / L`** *(or Arrows)* | Move Window Left / Down / Up / Right |
| **`Super + Ctrl + H / J / K / L`** *(or `-` / `=`)* | Resize Window Left / Down / Up / Right |
| **`Super + V`** *(or `Super + \`)* | Toggle Split Orientation (Dwindle Horizontal/Vertical) |
| **`Super + F`** / **`Super + M`** | Fullscreen / Maximize (keep Waybar visible) |
| **`Super + Shift + Space`** | Toggle Floating Window |
| **`Super + Q`** *(or `Super + W`)* | Close Active Window |
| **`Super + 1..0`** | Switch to Workspace 1–10 |
| **`Super + Shift + 1..0`** | Move Active Window to Workspace 1–10 |
| **`Super + S`** / **`Super + Shift + S`** | Toggle Scratchpad / Move Window to Scratchpad |
| **`Print`** *(or `Super + P`)* | Screenshot Region -> Clipboard + `~/Pictures/Screenshots/` |
| **`Shift + Print`** / **`Alt + Print`** | Screenshot Fullscreen / Screenshot Active Window |
| **`Super + Shift + C`** | Color Picker (`hyprpicker` -> Hex to Clipboard) |
| **`Super + C`** | Clipboard History (`cliphist` + Rofi) |
| **`Super + Shift + T`** | Theme Selector (`theme-switcher`) |
| **`Super + N`** | Toggle Notification Center (`swaync`) |
| **`Super + Escape`** *(or `Super + X`)* | Power Menu (Lock, Suspend, Logout, Reboot, Shutdown) |
| **`Super + Ctrl + L`** | Lock Screen Immediately (`hyprlock`) |
| **`Super + /`** *(or `Super + ?`)* | Open Searchable Keybind Cheat Sheet |
| **`CapsLock`** | Switch Keyboard Layout (`us` <-> `it`) |

---

## Guide for Future AI Agents

When assisting the user with modifications to this desktop setup, follow these architectural rules:

1. **Hyprland `0.55+` / `0.57+` Uses Native Lua (`hyprland.lua`)**:
   - CachyOS's Hyprland package (`0.57+`) evaluates `~/.config/hypr/hyprland.lua` using the `hl.*` Lua API (type stubs are located at `/usr/share/hypr/stubs/hl.meta.lua`).
   - Do **not** create legacy `hyprland.conf` files unless specifically requested; edit `config/hypr/hyprland.lua`.
   - Common API patterns:
     - Config options: `hl.config({ general = { ... }, decoration = { ... }, input = { ... } })`
     - Keybindings: `hl.bind("SUPER + H", hl.dsp.focus({ direction = "l" }), { description = "..." })`
     - Release keybinds (`bindr` equivalent): `hl.bind("SUPER + SUPER_L", hl.dsp.exec_cmd("..."), { release = true })`
     - Repeating/locked keybinds: `{ repeating = true, locked = true }`
     - Window rules: `hl.window_rule({ match = { class = "^(...)$" }, float = true })`
2. **Theme System Architecture (`bin/theme-switcher`)**:
   - Never hardcode hex colors inside `config/waybar/style.css`, `config/rofi/theme.rasi`, `config/kitty/kitty.conf`, or `config/swaync/style.css`.
   - Instead, use the color variables generated by `bin/theme-switcher`:
     - Waybar & SwayNC (`@bg`, `@bg_alt`, `@surface`, `@fg`, `@fg_dim`, `@accent`, `@accent2`, `@urgent`, `@green`, `@yellow`, `@cyan`).
     - Rofi (`@bg`, `@bg-alt`, `@surface`, `@fg`, `@fg-dim`, `@accent`, `@accent2`, `@urgent`).
     - Hyprland (`theme.active_border`, `theme.inactive_border` loaded via `require("theme")`).
   - To add a new theme, add a case block in `bin/theme-switcher`, add its RGB tuple to `apply.sh` (`generate_wallpapers`), and run `theme-switcher "<Theme Name>"`.
3. **Syncing Workflow**:
   - Always keep `~/src/vince-hyper` and the live `~/.config` / `~/.local/bin` in sync!
   - Either edit files inside `~/src/vince-hyper` and run `./apply.sh`, or edit live files in `~/.config` and run `./apply.sh --sync-back`.
4. **Privacy / Public Repo Safety**:
   - Never commit hardcoded usernames, hostnames, MAC addresses, Wi-Fi SSIDs, or tokens. Use `$HOME` or `~` in scripts and configs.
