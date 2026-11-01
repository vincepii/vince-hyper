#!/usr/bin/env bash
# ==============================================================================
# vince-hyper: Apply / Bootstrap Script
# ==============================================================================
# Applies this repository's Hyprland desktop configuration to the current user's
# environment (~/.config, ~/.local/bin, ~/.local/share/wallpapers).
#
# Usage:
#   ./apply.sh              # Copy configs & scripts, generate wallpapers, apply theme
#   ./apply.sh --packages   # Also install required Arch/CachyOS packages via pacman
#   ./apply.sh --sync-back  # Pull live changes from ~/.config & ~/.local/bin into repo
# ==============================================================================

set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

REQUIRED_PKGS=(
    hyprland
    hyprpaper
    hyprlock
    hypridle
    hyprpicker
    hyprpolkitagent
    xdg-desktop-portal-hyprland
    waybar
    rofi
    swaync
    kitty
    nautilus
    wl-clipboard
    cliphist
    grim
    slurp
    satty
    libnotify
    pavucontrol
    nm-connection-editor
    network-manager-applet
    blueman
    brightnessctl
    playerctl
    btop
    jq
    python
    greetd
    greetd-tuigreet
    ttf-jetbrains-mono-nerd
    noto-fonts
    noto-fonts-emoji
)

sync_back() {
    echo "==> Syncing live configs from ~/.config and ~/.local/bin back into $REPO_DIR..."
    cp -a "$HOME/.config/hypr/hyprland.lua" \
          "$HOME/.config/hypr/hyprlock.conf" \
          "$HOME/.config/hypr/hypridle.conf" \
          "$HOME/.config/hypr/hyprpaper.conf" \
          "$HOME/.config/hypr/theme.lua" \
          "$REPO_DIR/config/hypr/"

    cp -a "$HOME/.config/waybar/config.jsonc" \
          "$HOME/.config/waybar/style.css" \
          "$HOME/.config/waybar/colors.css" \
          "$REPO_DIR/config/waybar/"

    cp -a "$HOME/.config/rofi/config.rasi" \
          "$HOME/.config/rofi/theme.rasi" \
          "$HOME/.config/rofi/colors.rasi" \
          "$REPO_DIR/config/rofi/"

    cp -a "$HOME/.config/kitty/kitty.conf" \
          "$HOME/.config/kitty/colors.conf" \
          "$REPO_DIR/config/kitty/"

    cp -a "$HOME/.config/swaync/config.json" \
          "$HOME/.config/swaync/style.css" \
          "$HOME/.config/swaync/colors.css" \
          "$REPO_DIR/config/swaync/"

    [[ -f "$HOME/.config/themes/current" ]] && cp -a "$HOME/.config/themes/current" "$REPO_DIR/config/themes/"
    [[ -f "$HOME/.config/uwsm/env" ]] && cp -a "$HOME/.config/uwsm/env" "$REPO_DIR/config/uwsm/"
    [[ -f "$HOME/.config/mimeapps.list" ]] && cp -a "$HOME/.config/mimeapps.list" "$REPO_DIR/config/"

    cp -a "$HOME/.local/bin/theme-switcher" \
          "$HOME/.local/bin/screenshot" \
          "$HOME/.local/bin/clipboard-menu" \
          "$HOME/.local/bin/power-menu" \
          "$HOME/.local/bin/keybinds-menu" \
          "$REPO_DIR/bin/"

    echo "==> Done! Run 'git status' or 'git diff' in $REPO_DIR to review changes."
}

generate_wallpapers() {
    echo "==> Generating minimal dark gradient wallpapers in ~/.local/share/wallpapers..."
    mkdir -p "$HOME/.local/share/wallpapers"
    python3 - << 'PYEOF'
import os, struct, zlib

def make_png(path, w, h, top_rgb, bot_rgb):
    raw = bytearray()
    for y in range(h):
        t = y / max(1, h - 1)
        r = int(top_rgb[0] * (1 - t) + bot_rgb[0] * t)
        g = int(top_rgb[1] * (1 - t) + bot_rgb[1] * t)
        b = int(top_rgb[2] * (1 - t) + bot_rgb[2] * t)
        row = b"\x00" + bytes([r, g, b]) * w
        raw.extend(row)
    def chunk(ctype, data):
        return struct.pack(">I", len(data)) + ctype + data + struct.pack(">I", zlib.crc32(ctype + data) & 0xffffffff)
    ihdr = struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0)
    png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", zlib.compress(bytes(raw), 6)) + chunk(b"IEND", b"")
    with open(path, "wb") as f:
        f.write(png)

base = os.path.expanduser("~/.local/share/wallpapers")
themes = {
    "tokyo-night.png":      ((22, 22, 30), (26, 27, 38)),
    "catppuccin-mocha.png": ((17, 17, 27), (30, 30, 46)),
    "gruvbox-dark.png":     ((29, 32, 33), (40, 40, 40)),
    "nord.png":             ((36, 41, 51), (46, 52, 64)),
    "rose-pine.png":        ((25, 23, 36), (31, 29, 46)),
    "everforest.png":       ((30, 35, 38), (45, 53, 59)),
    "catppuccin-latte.png": ((230, 233, 239), (239, 241, 245)),
    "gruvbox-light.png":    ((242, 229, 188), (251, 241, 199)),
    "rose-pine-dawn.png":   ((242, 233, 225), (250, 244, 237)),
    "solarized-light.png":  ((238, 232, 213), (253, 246, 227)),
}
for name, (top, bot) in themes.items():
    make_png(os.path.join(base, name), 1920, 1080, top, bot)
PYEOF
}

if [[ "${1:-}" == "--sync-back" ]]; then
    sync_back
    exit 0
fi

if [[ "${1:-}" == "--packages" ]]; then
    echo "==> Installing required packages via pacman..."
    sudo pacman -S --needed "${REQUIRED_PKGS[@]}"
fi

# 1. Backup existing configs if present
TIMESTAMP="$(date +'%Y%m%d-%H%M%S')"
BACKUP_DIR="$HOME/.cache/vince-hyper-backup-$TIMESTAMP"
mkdir -p "$BACKUP_DIR"
for dir in hypr waybar rofi kitty swaync themes uwsm; do
    if [[ -d "$HOME/.config/$dir" ]]; then
        cp -a "$HOME/.config/$dir" "$BACKUP_DIR/"
    fi
done
echo "==> Previous configs backed up to: $BACKUP_DIR"

# 2. Create target directories
mkdir -p "$HOME/.config/hypr" \
         "$HOME/.config/waybar" \
         "$HOME/.config/rofi" \
         "$HOME/.config/kitty" \
         "$HOME/.config/swaync" \
         "$HOME/.config/themes" \
         "$HOME/.config/uwsm" \
         "$HOME/.local/bin" \
         "$HOME/.local/share/wallpapers" \
         "$HOME/Pictures/Screenshots"

# 3. Copy configs & helper scripts
echo "==> Installing configurations into ~/.config..."
cp -a "$REPO_DIR/config/hypr/"*   "$HOME/.config/hypr/"
cp -a "$REPO_DIR/config/waybar/"* "$HOME/.config/waybar/"
cp -a "$REPO_DIR/config/rofi/"*   "$HOME/.config/rofi/"
cp -a "$REPO_DIR/config/kitty/"*  "$HOME/.config/kitty/"
cp -a "$REPO_DIR/config/swaync/"* "$HOME/.config/swaync/"
cp -a "$REPO_DIR/config/themes/"* "$HOME/.config/themes/"
cp -a "$REPO_DIR/config/uwsm/"*   "$HOME/.config/uwsm/"
cp -a "$REPO_DIR/config/mimeapps.list" "$HOME/.config/mimeapps.list"

echo "==> Installing utility scripts into ~/.local/bin..."
cp -a "$REPO_DIR/bin/"* "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/theme-switcher" \
         "$HOME/.local/bin/screenshot" \
         "$HOME/.local/bin/clipboard-menu" \
         "$HOME/.local/bin/power-menu" \
         "$HOME/.local/bin/keybinds-menu"

# 4. Ensure ~/.local/bin is in shell PATHs
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [[ -f "$rc" ]] && ! grep -q '\.local/bin' "$rc"; then
        sed -i '1i export PATH="$HOME/.local/bin:$PATH"' "$rc"
    fi
done
if [[ -f "$HOME/.config/fish/config.fish" ]] && ! grep -q '\.local/bin' "$HOME/.config/fish/config.fish"; then
    sed -i '1i fish_add_path -g $HOME/.local/bin' "$HOME/.config/fish/config.fish"
fi

# 5. Optional non-intrusive SSH Agent socket setup (only if openssh + systemd user socket exist)
if systemctl --user list-unit-files ssh-agent.socket >/dev/null 2>&1; then
    systemctl --user enable --now ssh-agent.socket >/dev/null 2>&1 || true
    if [[ -f "$HOME/.config/fish/config.fish" ]] && ! grep -q 'SSH_AUTH_SOCK' "$HOME/.config/fish/config.fish"; then
        cat >> "$HOME/.config/fish/config.fish" << 'FISHEOF'

# Use systemd user ssh-agent socket if available and SSH_AUTH_SOCK is not already set
if not set -q SSH_AUTH_SOCK; and test -S "$XDG_RUNTIME_DIR/ssh-agent.socket"
    set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"
end
FISHEOF
    fi
fi

# 6. Generate wallpapers & apply theme
generate_wallpapers
CURRENT_THEME="$(cat "$HOME/.config/themes/current" 2>/dev/null || echo "Tokyo Night")"
"$HOME/.local/bin/theme-switcher" "$CURRENT_THEME"

echo "==> Successfully applied vince-hyper ($CURRENT_THEME)!"
