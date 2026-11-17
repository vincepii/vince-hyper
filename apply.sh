#!/usr/bin/env bash
# ==============================================================================
# vince-hyper: Apply / Bootstrap / Upgrade Script
# ==============================================================================
# Applies this repository's Hyprland desktop configuration to the current user's
# environment (~/.config, ~/.local/bin, ~/.local/share/wallpapers) and ensures
# all required packages are installed.
#
# Usage:
#   ./apply.sh              # Install any missing packages, apply configs, keep current theme
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
    rofimoji
    wtype
    swaync
    swayosd
    libqalculate
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
    xorg-xrdb
    papirus-icon-theme
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
          "$REPO_DIR/config/hypr/"

    cp -a "$HOME/.config/waybar/config.jsonc" \
          "$HOME/.config/waybar/style.css" \
          "$REPO_DIR/config/waybar/"

    # Normalize theme-synced Pango hex colors in repo's config/waybar/config.jsonc back to Tokyo Night defaults
    python3 - "$REPO_DIR/config/waybar/config.jsonc" << 'PYEOF'
import json, sys

cfg_path = sys.argv[1]
accent, accent2, fg, fg_dim, bg, urgent = "#7aa2f7", "#bb9af7", "#c0caf5", "#565f89", "#1a1b26", "#f7768e"
with open(cfg_path, "r", encoding="utf-8") as f:
    cfg = json.load(f)

clock = cfg.setdefault("clock", {})
clock["tooltip-format"] = (
    f"<span font_family='JetBrainsMono Nerd Font' size='15pt' weight='bold' color='{accent}'>󰃭  {{:%A, %d %B %Y}}</span>\n\n"
    f"<span font_family='JetBrainsMono Nerd Font' size='16pt' line_height='1.35'>{{calendar}}</span>\n\n"
    f"<span font_family='JetBrainsMono Nerd Font' size='9.5pt' color='{fg_dim}'>󰍽 Scroll: Prev/Next   •   Right-Click: Year View</span>"
)
cal_fmt = clock.setdefault("calendar", {}).setdefault("format", {})
cal_fmt["months"]   = f"<span font_family='JetBrainsMono Nerd Font' color='{accent2}'><b>{{}}</b></span>"
cal_fmt["days"]     = f"<span font_family='JetBrainsMono Nerd Font' color='{fg}'>{{}}</span>"
cal_fmt["weeks"]    = f"<span font_family='JetBrainsMono Nerd Font' color='{fg_dim}'><b>W{{}}</b></span>"
cal_fmt["weekdays"] = f"<span font_family='JetBrainsMono Nerd Font' color='{accent}'><b>{{}}</b></span>"
cal_fmt["today"]    = f"<span font_family='JetBrainsMono Nerd Font' background='{accent}' color='{bg}'><b>{{}}</b></span>"

notif = cfg.get("custom/notification", {}).get("format-icons")
if isinstance(notif, dict):
    dot = f"<span foreground='{urgent}'><sup></sup></span>"
    notif["notification"]               = f"󰂚{dot}"
    notif["dnd-notification"]           = f"󰂛{dot}"
    notif["inhibited-notification"]     = f"󰂚{dot}"
    notif["dnd-inhibited-notification"] = f"󰂛{dot}"

with open(cfg_path, "w", encoding="utf-8") as f:
    json.dump(cfg, f, ensure_ascii=False, indent=2)
    f.write("\n")
PYEOF

    cp -a "$HOME/.config/rofi/config.rasi" \
          "$HOME/.config/rofi/theme.rasi" \
          "$REPO_DIR/config/rofi/"
    sed -i 's|icon-theme:.*;|icon-theme:                 "Papirus-Dark";|' "$REPO_DIR/config/rofi/config.rasi" 2>/dev/null || true

    cp -a "$HOME/.config/kitty/kitty.conf" \
          "$REPO_DIR/config/kitty/"

    cp -a "$HOME/.config/swaync/config.json" \
          "$HOME/.config/swaync/style.css" \
          "$REPO_DIR/config/swaync/"

    mkdir -p "$REPO_DIR/config/fontconfig"
    [[ -f "$HOME/.config/fontconfig/fonts.conf" ]] && cp -a "$HOME/.config/fontconfig/fonts.conf" "$REPO_DIR/config/fontconfig/"
    [[ -f "$HOME/.config/uwsm/env" ]] && cp -a "$HOME/.config/uwsm/env" "$REPO_DIR/config/uwsm/"
    [[ -f "$HOME/.config/mimeapps.list" ]] && cp -a "$HOME/.config/mimeapps.list" "$REPO_DIR/config/"

    cp -a "$HOME/.local/bin/theme-switcher" \
          "$HOME/.local/bin/wallpaper-switcher" \
          "$HOME/.local/bin/switch-layout" \
          "$HOME/.local/bin/rofi-calc" \
          "$HOME/.local/bin/screenshot" \
          "$HOME/.local/bin/clipboard-menu" \
          "$HOME/.local/bin/power-menu" \
          "$HOME/.local/bin/keybinds-menu" \
          "$REPO_DIR/bin/"

    echo "==> Done! Run 'git status' or 'git diff' in $REPO_DIR to review changes."
}

generate_wallpapers() {
    echo "==> Ensuring minimal gradient wallpapers exist in ~/.local/share/wallpapers..."
    mkdir -p "$HOME/.local/share/wallpapers"
    python3 - << 'PYEOF'
import os, struct, zlib

def make_png(path, w, h, top_rgb, bot_rgb):
    if os.path.exists(path):
        return
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
    "tokyo-night-day.png":  ((208, 213, 227), (225, 226, 231)),
    "catppuccin-latte.png": ((230, 233, 239), (239, 241, 245)),
    "gruvbox-light.png":    ((242, 229, 188), (251, 241, 199)),
    "rose-pine-dawn.png":   ((242, 233, 225), (250, 244, 237)),
    "everforest-light.png": ((244, 240, 217), (253, 246, 227)),
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

# 1. Check for any missing packages and install them automatically
MISSING_PKGS=()
for pkg in "${REQUIRED_PKGS[@]}"; do
    if ! pacman -Qq "$pkg" >/dev/null 2>&1; then
        MISSING_PKGS+=("$pkg")
    fi
done

if [[ ${#MISSING_PKGS[@]} -gt 0 ]]; then
    echo "==> Installing missing packages: ${MISSING_PKGS[*]}"
    sudo pacman -S --needed "${MISSING_PKGS[@]}"
else
    echo "==> All required packages are already installed."
fi

# Configure SwayOSD libinput backend (preserving any existing TOML sections) to ignore CapsLock
# and immediately restart swayosd-libinput-backend.service if running/enabled.
if systemctl is-enabled swayosd-libinput-backend.service >/dev/null 2>&1 \
   || systemctl is-active swayosd-libinput-backend.service >/dev/null 2>&1 \
   || [[ -d /etc/xdg/swayosd ]]; then
    if [[ ! -f /etc/xdg/swayosd/backend.toml ]] || ! grep -Eq '^[[:space:]]*ignore_caps_lock_key[[:space:]]*=[[:space:]]*true' /etc/xdg/swayosd/backend.toml 2>/dev/null; then
        echo "==> Configuring /etc/xdg/swayosd/backend.toml (ignore_caps_lock_key = true)..."
        sudo mkdir -p /etc/xdg/swayosd
        TMP_TOML="$(mktemp)"
        python3 - /etc/xdg/swayosd/backend.toml "$TMP_TOML" << 'PYEOF'
import os, re, sys

src, dst = sys.argv[1], sys.argv[2]
text = ""
if os.path.exists(src):
    with open(src, "r", encoding="utf-8") as f:
        text = f.read()

if re.search(r"(?m)^\[input\]\s*$", text):
    def patch_input(match):
        body = match.group(2)
        if re.search(r"(?m)^\s*ignore_caps_lock_key\s*=", body):
            body = re.sub(r"(?m)^\s*ignore_caps_lock_key\s*=.*$", "ignore_caps_lock_key = true", body)
        else:
            body = "ignore_caps_lock_key = true\n" + body
        return match.group(1) + body
    text = re.sub(r"(?ms)(^\[input\]\s*\n)(.*?)(?=^\[|\Z)", patch_input, text, count=1)
else:
    if text and not text.endswith("\n"):
        text += "\n"
    if text:
        text += "\n"
    text += "[input]\nignore_caps_lock_key = true\n"

with open(dst, "w", encoding="utf-8") as f:
    f.write(text)
PYEOF
        sudo install -m 0644 "$TMP_TOML" /etc/xdg/swayosd/backend.toml || true
        rm -f "$TMP_TOML"
        if systemctl is-active --quiet swayosd-libinput-backend.service || systemctl is-enabled --quiet swayosd-libinput-backend.service 2>/dev/null; then
            sudo systemctl restart swayosd-libinput-backend.service 2>/dev/null || true
        fi
    fi
fi

# 2. Remember user's currently active theme before touching ~/.config
CURRENT_THEME=""
if [[ -f "$HOME/.config/themes/current" ]]; then
    CURRENT_THEME="$(cat "$HOME/.config/themes/current")"
fi

# 3. Backup existing configs if present
TIMESTAMP="$(date +'%Y%m%d-%H%M%S')"
BACKUP_DIR="$HOME/.cache/vince-hyper-backup-$TIMESTAMP"
mkdir -p "$BACKUP_DIR"
for dir in hypr waybar rofi kitty swaync fontconfig themes uwsm; do
    if [[ -d "$HOME/.config/$dir" ]]; then
        cp -a "$HOME/.config/$dir" "$BACKUP_DIR/"
    fi
done
echo "==> Previous configs backed up to: $BACKUP_DIR"

# 4. Create target directories
mkdir -p "$HOME/.config/hypr" \
         "$HOME/.config/waybar" \
         "$HOME/.config/rofi" \
         "$HOME/.config/kitty" \
         "$HOME/.config/swaync" \
         "$HOME/.config/fontconfig" \
         "$HOME/.config/themes" \
         "$HOME/.config/uwsm" \
         "$HOME/.local/bin" \
         "$HOME/.local/share/wallpapers" \
         "$HOME/Pictures/Screenshots"

# 5. Copy configs & helper scripts
echo "==> Installing configurations into ~/.config..."
cp -a "$REPO_DIR/config/hypr/"*       "$HOME/.config/hypr/"
cp -a "$REPO_DIR/config/waybar/"*     "$HOME/.config/waybar/"
cp -a "$REPO_DIR/config/rofi/"*       "$HOME/.config/rofi/"
cp -a "$REPO_DIR/config/kitty/"*      "$HOME/.config/kitty/"
cp -a "$REPO_DIR/config/swaync/"*     "$HOME/.config/swaync/"
cp -a "$REPO_DIR/config/fontconfig/"* "$HOME/.config/fontconfig/"
cp -a "$REPO_DIR/config/uwsm/"*       "$HOME/.config/uwsm/"
cp -a "$REPO_DIR/config/mimeapps.list" "$HOME/.config/mimeapps.list"

echo "==> Installing utility scripts into ~/.local/bin..."
cp -a "$REPO_DIR/bin/"* "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/theme-switcher" \
         "$HOME/.local/bin/wallpaper-switcher" \
         "$HOME/.local/bin/switch-layout" \
         "$HOME/.local/bin/rofi-calc" \
         "$HOME/.local/bin/screenshot" \
         "$HOME/.local/bin/clipboard-menu" \
         "$HOME/.local/bin/power-menu" \
         "$HOME/.local/bin/keybinds-menu"

# 6. Ensure ~/.local/bin is in shell PATHs
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [[ -f "$rc" ]] && ! grep -q '\.local/bin' "$rc"; then
        sed -i '1i export PATH="$HOME/.local/bin:$PATH"' "$rc"
    fi
done
if [[ -f "$HOME/.config/fish/config.fish" ]] && ! grep -q '\.local/bin' "$HOME/.config/fish/config.fish"; then
    sed -i '1i fish_add_path -g $HOME/.local/bin' "$HOME/.config/fish/config.fish"
fi

# 7. Optional non-intrusive SSH Agent socket setup (only if openssh + systemd user socket exist)
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

# 8. Refresh font cache & start SwayOSD if running inside Hyprland
fc-cache -f >/dev/null 2>&1 || true
if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && command -v swayosd-server >/dev/null 2>&1; then
    if ! pgrep -x swayosd-server >/dev/null 2>&1; then
        nohup swayosd-server >/dev/null 2>&1 &
        disown
    fi
fi

# 9. Generate wallpapers & re-apply user's active theme (or Tokyo Night on first install)
generate_wallpapers
if [[ -z "$CURRENT_THEME" ]]; then
    CURRENT_THEME="Tokyo Night"
fi
"$HOME/.local/bin/theme-switcher" "$CURRENT_THEME"

echo "==> Successfully applied vince-hyper (Theme: $CURRENT_THEME)!"
