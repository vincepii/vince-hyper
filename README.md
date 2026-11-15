# vince-hyper

A minimal, fast, productivity-focused **Hyprland (`0.55+` / `0.57+` native Lua)** desktop configuration for **CachyOS / Arch Linux**.

A clean aesthetic with a floating pill-based Waybar and a curated 12-theme switcher (6 Dark + 6 Light), paired with classic **i3 / Vim (`H/J/K/L`) dwindle window management** and standard, battle-tested Wayland components (**Waybar**, **Rofi**, **SwayNC**, **SwayOSD**, **Kitty**, **Cliphist**, **Grim/Slurp/Satty**).

---

## Philosophy & Design Goals

1. **Zero Bloat / No Gimmicks**: No custom Quickshell/AGS/Astal daemons, no audio visualizer bars, no docks, no anime wallpapers. Just a crisp floating pill top panel and fast keyboard-driven workflows.
2. **Standard i3 / Vim Navigation**: `Super + H/J/K/L` always focuses windows (`Left/Down/Up/Right`, stopping cleanly at screen edges), `Super + Shift + H/J/K/L` moves windows, and `Super + Ctrl + H/J/K/L` resizes windows.
3. **Unified 12-Palette Theme Switcher**: One script (`theme-switcher`) simultaneously updates **Hyprland borders**, **Waybar floating pills**, **Rofi**, **Kitty**, **SwayNC**, **GTK 3/4 themes (`Adwaita-dark` / `Adwaita`)**, **Papirus icons (`Papirus-Dark` / `Papirus-Light`)**, and **Hyprpaper** wallpapers across 12 palettes (6 dark + 6 light):
   - **Dark**: **Tokyo Night** *(default)*, **Catppuccin Mocha**, **Gruvbox Dark**, **Nord**, **Rosé Pine**, **Everforest**
   - **Light**: **Tokyo Night Day (Light)**, **Catppuccin Latte (Light)**, **Gruvbox Light**, **Rose Pine Dawn (Light)**, **Everforest Light**, **Solarized Light**
4. **Fractional Scaling (`1.25x`) & Compositor Efficiency**: Tuned fontconfig (`hintnone`, grayscale AA, no stem darkening) and `Xft.dpi: 120` for razor-sharp rendering at `1.25x` scale, Smart Gaps when a single tiled window is open, VFR + direct scanout for minimal GPU usage, and multi-device synchronized `US` <-> `IT` keyboard layout switching with SwayOSD feedback.
5. **Portable & Self-Contained**: No external dotfile managers, symlink farms, or Python virtualenvs required. `apply.sh` deploys everything cleanly and generates minimal gradient wallpapers programmatically.

---

## Repository Structure

```text
vince-hyper/
├── apply.sh                  # Bootstrap & sync script (apply / upgrade, --sync-back)
├── README.md                 # User & AI Agent architecture documentation
├── bin/                      # Installed to ~/.local/bin/
│   ├── theme-switcher        # Rofi theme selector + multi-app / GTK / Papirus palette generator
│   ├── wallpaper-switcher    # Rofi wallpaper selector (Pictures/Wallpapers + System)
│   ├── switch-layout         # Synchronized multi-device keyboard layout switcher (US <-> IT) + SwayOSD
│   ├── rofi-calc             # Inline Rofi calculator mode (qalc + Python math fallback + wl-copy)
│   ├── screenshot            # grim + slurp + satty + wl-copy screenshot utility
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
    │   ├── config.jsonc      # Floating pill top panel layout & module definitions
    │   ├── style.css         # Floating pill panel styling with per-module semantic colors
    │   └── colors.css        # Auto-generated palette variables (including @bg_bar, @bg_pill, @dark_text)
    ├── rofi/
    │   ├── config.rasi       # Rofi modes (drun, run, window, calc), Papirus icons & vim keybinds
    │   ├── theme.rasi        # Launcher layout & styling (imports colors.rasi)
    │   └── colors.rasi       # Auto-generated palette variables
    ├── kitty/
    │   ├── kitty.conf        # Terminal font, padding, tab bar (includes colors.conf)
    │   └── colors.conf       # Auto-generated 16-color terminal palette
    ├── swaync/
    │   ├── config.json       # Notification daemon & control center config
    │   ├── style.css         # Notification styling (imports colors.css)
    │   └── colors.css        # Auto-generated palette variables
    ├── fontconfig/
    │   └── fonts.conf        # Fontconfig tuned for 1.25x fractional scaling (hintnone, grayscale AA)
    ├── themes/
    │   └── current           # Stores active theme name
    ├── uwsm/
    │   └── env               # Wayland environment variables
    └── mimeapps.list         # Default file manager (Nautilus) & browser associations
```

---

## Quick Start / Installation

### 1. Install or Update (Fresh or Existing System)
```bash
git clone git@github.com:vincepii/vince-hyper.git ~/src/vincepii/vince-hyper
cd ~/src/vincepii/vince-hyper
./apply.sh
```
`./apply.sh` automatically:
1. Checks if any required packages are missing and installs only the missing ones via `pacman`.
2. Backs up your existing `~/.config` directories to `~/.cache/vince-hyper-backup-<timestamp>`.
3. Deploys all configurations and scripts, generates the gradient wallpapers, and **preserves your currently active theme** (defaulting to **Tokyo Night** only on a brand-new installation).

*(Note: Google Chrome is launched via `flatpak run com.google.Chrome` by default. If you use native Chrome or another browser, update `local browser` in `config/hypr/hyprland.lua`.)*

### 2. Saving Local Tweaks Back to the Repo
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
| **`Super + =`** | Inline Calculator (`rofi-calc` / `qalc`, auto-copies result to clipboard) |
| **`Super + .`** | Emoji Picker (`rofimoji` -> copies emoji to clipboard) |
| **`Super + Return`** | Terminal (`kitty`) |
| **`Super + B`** | Browser (`Google Chrome`) |
| **`Super + E`** | File Manager (`nautilus`) |
| **`Ctrl + Shift + Escape`** | Toggle Centered Floating System Monitor (`btop`) |
| **`Super + H / J / K / L`** *(or Arrows)* | Focus Left / Down / Up / Right (stops at screen edge) |
| **`Super + Shift + H / J / K / L`** *(or Arrows)* | Move Window Left / Down / Up / Right |
| **`Super + Ctrl + H / J / K / L`** *(or Arrows)* | Resize Window Left / Down / Up / Right |
| **`Super + O`** *(or `Super + \`)* | Toggle Split Orientation (Dwindle Horizontal/Vertical) |
| **`Super + F`** / **`Super + M`** | Fullscreen (inhibits idle) / Maximize (keep Waybar visible) |
| **`Super + Shift + Space`** | Toggle Floating Window |
| **`Super + Q`** *(or `Super + W`)* | Close Active Window |
| **`Super + 1..0`** | Switch to Workspace 1–10 |
| **`Super + Shift + 1..0`** | Move Active Window to Workspace 1–10 (and follow) |
| **`Super + Ctrl + 1..0`** | Move Active Window Silently to Workspace 1–10 (stay on current workspace) |
| **`Super + [`** / **`Super + ]`** | Cycle Previous / Next Workspace (`e-1` / `e+1`) |
| **`Super + \`` (Grave)** / **`Super + Shift + \``** | Toggle Scratchpad / Move Window to Scratchpad |
| **`Super + Shift + S`** *(or `Print`)* | Screenshot Region -> Clipboard + `~/Pictures/Screenshots/` |
| **`Super + S`** *(or `Super + Alt + S`)* | Screenshot Region + Edit/Annotate (`satty`) -> Clipboard + Save |
| **`Super + Ctrl + S`** *(or `Shift + Print`)* | Screenshot Fullscreen -> Clipboard + Save |
| **`Super + P`** *(or `Alt + Print`)* | Screenshot Active Window -> Clipboard + Save |
| **`Super + Shift + C`** | Color Picker (`hyprpicker` -> Hex to Clipboard) |
| **`Super + V`** *(or `Super + C`)* | Clipboard History (`cliphist` + Rofi) |
| **`Super + Shift + T`** | Theme Selector (`theme-switcher`, 12 Dark & Light themes) |
| **`Super + Shift + W`** | Wallpaper Selector (`wallpaper-switcher` / Right-click `󰔎` in bar) |
| **`Super + N`** | Toggle Notification Center (`swaync`) |
| **`Super + Escape`** *(or `Super + X`)* | Power Menu (Lock, Suspend, Logout, Reboot, Shutdown) |
| **`Ctrl + Alt + L`** | Lock Screen Immediately (`hyprlock`) |
| **`Super + /`** *(or `Super + ?`)* | Open Searchable Keybind Cheat Sheet |
| **`CapsLock`** / **`Super + Ctrl + Space`** | Switch Keyboard Layout (`US` <-> `IT`) across all devices + SwayOSD |

---

## Guide for Future AI Agents

When assisting the user with modifications to this desktop setup, follow these architectural rules:

1. **Hyprland `0.55+` / `0.57+` Uses Native Lua (`hyprland.lua`)**:
   - CachyOS's Hyprland package (`0.57+`) evaluates `~/.config/hypr/hyprland.lua` using the `hl.*` Lua API (type stubs are located at `/usr/share/hypr/stubs/hl.meta.lua`).
   - Do **not** create legacy `hyprland.conf` files unless specifically requested; edit `config/hypr/hyprland.lua`.
   - You can validate `hyprland.lua` at any time using `Hyprland --verify-config -c config/hypr/hyprland.lua`.
   - Common API patterns:
     - Config options: `hl.config({ general = { ... }, decoration = { ... }, input = { ... }, debug = { vfr = true }, render = { direct_scanout = 1 } })`
     - Keybindings: `hl.bind("SUPER + H", hl.dsp.focus({ direction = "l" }), { description = "..." })`
     - Release keybinds (`bindr` equivalent): `hl.bind("SUPER + SUPER_L", hl.dsp.exec_cmd("..."), { release = true })`
     - Repeating/locked keybinds: `{ repeating = true, locked = true }`
     - Window rules: `hl.window_rule({ match = { class = "^(...)$" }, float = true })`
     - Workspace rules: `hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })`
2. **Theme System Architecture (`bin/theme-switcher`)**:
   - Never hardcode hex colors inside `config/waybar/style.css`, `config/rofi/theme.rasi`, `config/kitty/kitty.conf`, or `config/swaync/style.css`.
   - Instead, use the color variables generated by `bin/theme-switcher`:
     - Waybar & SwayNC (`@bg`, `@bg_alt`, `@bg_bar`, `@bg_pill`, `@surface`, `@fg`, `@fg_dim`, `@accent`, `@accent2`, `@urgent`, `@green`, `@yellow`, `@cyan`, `@orange`, `@pink`, `@teal`, `@dark_text`).
     - Rofi (`@bg`, `@bg-alt`, `@surface`, `@fg`, `@fg-dim`, `@accent`, `@accent2`, `@urgent`).
     - Hyprland (`theme.active_border`, `theme.inactive_border` loaded via `require("theme")`).
   - `bin/theme-switcher` also syncs GTK 3/4 `settings.ini`, `gsettings` (`Adwaita-dark` vs `Adwaita`, `Papirus-Dark` vs `Papirus-Light`, font rendering), and Rofi's `icon-theme`. Use `theme-switcher --restore` at startup to restore settings quietly without sending a desktop notification.
   - To add a new theme, add a case block in `bin/theme-switcher`, add its RGB tuple to `apply.sh` (`generate_wallpapers`), and run `theme-switcher "<Theme Name>"`.
3. **Keyboard Layout Switching (`bin/switch-layout`)**:
   - Do **not** use `kb_options = "grp:caps_toggle"` or `hyprctl switchxkblayout all next`—on multi-interface keyboards they desynchronize the physical keyboard from Waybar's `hyprland/language` module.
   - Instead, `kb_options` is set to `"caps:none"` and `code:66` (`CapsLock`), `Super + Ctrl + Space`, and Waybar's language pill all invoke `~/.local/bin/switch-layout`, which queries the main keyboard's `active_layout_index` and forces all keyboard devices onto explicit index `0` (`US`) or `1` (`IT`).
4. **Syncing Workflow**:
   - Always keep `~/src/vincepii/vince-hyper` and the live `~/.config` / `~/.local/bin` in sync!
   - Either edit files inside `~/src/vincepii/vince-hyper` and run `./apply.sh`, or edit live files in `~/.config` and run `./apply.sh --sync-back`.
5. **Privacy / Public Repo Safety**:
   - Never commit hardcoded usernames, hostnames, MAC addresses, Wi-Fi SSIDs, or tokens. Use `$HOME` or `~` in scripts and configs.
