-- ============================================================================
-- Hyprland 0.57+ Configuration (Clean Power-User + i3 Dwindle Setup)
-- ============================================================================

local home = os.getenv("HOME")
package.path = home .. "/.config/hypr/?.lua;" .. package.path

local ok, theme = pcall(require, "theme")
if not ok or type(theme) ~= "table" then
    theme = {
        active_border   = { colors = { "rgba(7aa2f7ee)", "rgba(bb9af7ee)" }, angle = 45 },
        inactive_border = "rgba(292e42aa)",
    }
end

------------------
---- MONITORS ----
------------------
hl.monitor({
    output   = "DP-1",
    mode     = "3840x2160@59.997",
    position = "0x0",
    scale    = 1.25,
})

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

---------------------
---- MY PROGRAMS ----
---------------------
local terminal    = "kitty"
local fileManager = "nautilus --new-window"
local browser     = "flatpak run com.google.Chrome"
local launcher    = "rofi -show drun"
local windowMenu  = "rofi -show window"
local clipMenu    = home .. "/.local/bin/clipboard-menu"
local themeMenu   = home .. "/.local/bin/theme-switcher"
local wallMenu    = home .. "/.local/bin/wallpaper-switcher"
local powerMenu   = home .. "/.local/bin/power-menu"
local keybindMenu = home .. "/.local/bin/keybinds-menu"
local screenshot  = home .. "/.local/bin/screenshot"

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("PATH", home .. "/.local/bin:" .. (os.getenv("PATH") or "/usr/local/bin:/usr/bin"))
if os.getenv("XDG_RUNTIME_DIR") then
    hl.env("SSH_AUTH_SOCK", os.getenv("XDG_RUNTIME_DIR") .. "/ssh-agent.socket")
end

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("nm-applet --indicator")
end)

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
    general = {
        gaps_in             = 4,
        gaps_out            = 8,
        border_size         = 2,
        resize_on_border    = true,
        allow_tearing       = false,
        layout              = "dwindle",
        col = {
            active_border   = theme.active_border,
            inactive_border = theme.inactive_border,
        },
    },

    decoration = {
        rounding         = 8,
        rounding_power   = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 16,
            render_power = 3,
            color        = "rgba(00000066)",
        },

        blur = {
            enabled           = true,
            size              = 4,
            passes            = 2,
            new_optimizations = true,
            vibrancy          = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split        = true,
        force_split           = 2, -- Always split to the right / bottom (predictable like i3)
        use_active_for_splits = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        middle_click_paste       = false,
        focus_on_activate        = true,
        vrr                      = 1,
    },

    ecosystem = {
        no_update_news  = true,
        no_donation_nag = true,
    },

    xwayland = {
        force_zero_scaling = true,
    },

    binds = {
        workspace_back_and_forth = false,
        allow_workspace_cycles   = true,
    },
})

-- Persistent workspaces 1..5 on DP-1 (so they are always visible & clickable in Waybar)
for i = 1, 5 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "DP-1", persistent = true })
end

--------------------
---- ANIMATIONS ----
--------------------
hl.curve("snappy",       { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })
hl.curve("almostLinear", { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("linear",       { type = "bezier", points = { {0, 0},       {1, 1}       } })

hl.animation({ leaf = "global",     enabled = true, speed = 3,   bezier = "snappy" })
hl.animation({ leaf = "border",     enabled = true, speed = 3,   bezier = "snappy" })
hl.animation({ leaf = "windows",    enabled = true, speed = 2.8, bezier = "snappy", style = "popin 90%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2,   bezier = "linear", style = "popin 90%" })
hl.animation({ leaf = "fade",       enabled = true, speed = 2.5, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3,   bezier = "snappy", style = "slide" })

---------------
---- INPUT ----
---------------
hl.config({
    input = {
        kb_layout          = "us,it",
        kb_options         = "grp:caps_toggle",
        numlock_by_default = true,
        follow_mouse       = 1,
        sensitivity        = 0,
        repeat_rate        = 40,
        repeat_delay       = 250,
        touchpad = {
            natural_scroll = true,
            tap_to_click   = true,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

-------------------------------------------------
---- KEYBINDINGS (i3 Dwindle + Power-User)   ----
-------------------------------------------------
local mainMod = "SUPER"

-- 1. Launcher: Tap Super alone (on release) OR Super + Space / Super + D
hl.bind("SUPER + SUPER_L",   hl.dsp.exec_cmd("pkill -x rofi || " .. launcher), { release = true, description = "Toggle App Launcher on Super tap" })
hl.bind(mainMod .. " + D",     hl.dsp.exec_cmd("pkill -x rofi || " .. launcher), { non_consuming = false, description = "App Launcher" })
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("pkill -x rofi || " .. launcher), { description = "App Launcher" })
hl.bind(mainMod .. " + Tab",   hl.dsp.exec_cmd("pkill -x rofi || " .. windowMenu), { description = "Window Switcher" })
hl.bind("ALT + Tab",           hl.dsp.window.cycle_next(), { description = "Cycle next window" })

-- 2. Core Applications
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal),    { description = "Terminal (Kitty)" })
hl.bind(mainMod .. " + B",      hl.dsp.exec_cmd(browser),     { description = "Browser (Chrome)" })
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager), { description = "File Manager (Nautilus)" })
hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd(terminal .. " -e btop"), { description = "System Monitor (btop)" })

-- 3. Window Management (i3 + Dwindle conventions)
hl.bind(mainMod .. " + Q",           hl.dsp.window.close(), { description = "Close active window" })
hl.bind(mainMod .. " + W",           hl.dsp.window.close(), { description = "Close active window" })
hl.bind(mainMod .. " + SHIFT + Q",   hl.dsp.window.close(), { description = "Close active window" })
hl.bind(mainMod .. " + SHIFT + Escape", hl.dsp.release_input_capture(), { dont_inhibit = true, description = "Force-release VM / Remote Desktop keyboard grab" })
hl.bind(mainMod .. " + F",           hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), { description = "Toggle Fullscreen" })
hl.bind(mainMod .. " + M",           hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }),  { description = "Toggle Maximize" })
hl.bind(mainMod .. " + SHIFT + Space", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle Floating" })
hl.bind(mainMod .. " + V",           hl.dsp.layout("togglesplit"), { description = "Toggle Split Orientation (Dwindle)" })
hl.bind(mainMod .. " + Backslash",   hl.dsp.layout("togglesplit"), { description = "Toggle Split Orientation (Dwindle)" })

-- 4. Focus Navigation: Super + H/J/K/L and Arrow Keys
hl.bind(mainMod .. " + H",     hl.dsp.focus({ direction = "l" }), { description = "Focus left" })
hl.bind(mainMod .. " + J",     hl.dsp.focus({ direction = "d" }), { description = "Focus down" })
hl.bind(mainMod .. " + K",     hl.dsp.focus({ direction = "u" }), { description = "Focus up" })
hl.bind(mainMod .. " + L",     hl.dsp.focus({ direction = "r" }), { description = "Focus right" })
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "l" }), { description = "Focus left" })
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "d" }), { description = "Focus down" })
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "u" }), { description = "Focus up" })
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }), { description = "Focus right" })

-- 5. Move Windows: Super + Shift + H/J/K/L and Arrow Keys
hl.bind(mainMod .. " + SHIFT + H",     hl.dsp.window.move({ direction = "l" }), { description = "Move window left" })
hl.bind(mainMod .. " + SHIFT + J",     hl.dsp.window.move({ direction = "d" }), { description = "Move window down" })
hl.bind(mainMod .. " + SHIFT + K",     hl.dsp.window.move({ direction = "u" }), { description = "Move window up" })
hl.bind(mainMod .. " + SHIFT + L",     hl.dsp.window.move({ direction = "r" }), { description = "Move window right" })
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "l" }), { description = "Move window left" })
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "d" }), { description = "Move window down" })
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "u" }), { description = "Move window up" })
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }), { description = "Move window right" })

-- 6. Resize Windows: Super + Ctrl + H/J/K/L and Arrow Keys (plus -/=)
hl.bind(mainMod .. " + CTRL + H",     hl.dsp.window.resize({ x = -60, y = 0,   relative = true }), { repeating = true, description = "Resize narrower" })
hl.bind(mainMod .. " + CTRL + L",     hl.dsp.window.resize({ x = 60,  y = 0,   relative = true }), { repeating = true, description = "Resize wider" })
hl.bind(mainMod .. " + CTRL + K",     hl.dsp.window.resize({ x = 0,   y = -60, relative = true }), { repeating = true, description = "Resize shorter" })
hl.bind(mainMod .. " + CTRL + J",     hl.dsp.window.resize({ x = 0,   y = 60,  relative = true }), { repeating = true, description = "Resize taller" })
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.resize({ x = -60, y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 60,  y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.resize({ x = 0,   y = -60, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.resize({ x = 0,   y = 60,  relative = true }), { repeating = true })
hl.bind(mainMod .. " + minus",        hl.dsp.window.resize({ x = -60, y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + equal",        hl.dsp.window.resize({ x = 60,  y = 0,   relative = true }), { repeating = true })

-- 7. Workspaces 1..10
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }),       { description = "Switch to workspace " .. i })
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), { description = "Move window to workspace " .. i })
end

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Scratchpad (Special Workspace)
hl.bind(mainMod .. " + grave",         hl.dsp.workspace.toggle_special("scratchpad"), { description = "Toggle Scratchpad" })
hl.bind(mainMod .. " + SHIFT + grave", hl.dsp.window.move({ workspace = "special:scratchpad" }), { description = "Send to Scratchpad" })

-- Mouse Drag & Resize
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- 8. Utilities: Clipboard, Theme Switcher, Wallpaper Switcher, Screenshots, Notifications, Power, Lock
hl.bind(mainMod .. " + C",         hl.dsp.exec_cmd(clipMenu),    { description = "Clipboard Manager" })
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd(themeMenu),   { description = "Theme Selector" })
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(wallMenu),    { description = "Wallpaper Selector" })
hl.bind(mainMod .. " + N",         hl.dsp.exec_cmd("swaync-client -t -sw"), { description = "Notification Center" })
hl.bind(mainMod .. " + Slash",     hl.dsp.exec_cmd(keybindMenu), { description = "Keybind Cheat Sheet" })
hl.bind(mainMod .. " + SHIFT + Slash", hl.dsp.exec_cmd(keybindMenu), { description = "Keybind Cheat Sheet" })

-- Screenshots (Print-less friendly + Print fallback)
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(screenshot .. " region"), { description = "Screenshot Region (Copy + Save)" })
hl.bind(mainMod .. " + S",         hl.dsp.exec_cmd(screenshot .. " edit"),   { description = "Screenshot Region + Annotate (satty)" })
hl.bind(mainMod .. " + ALT + S",   hl.dsp.exec_cmd(screenshot .. " edit"),   { description = "Screenshot Region + Annotate (satty)" })
hl.bind(mainMod .. " + CTRL + S",  hl.dsp.exec_cmd(screenshot .. " full"),   { description = "Screenshot Fullscreen" })
hl.bind(mainMod .. " + P",         hl.dsp.exec_cmd(screenshot .. " window"), { description = "Screenshot Active Window" })
hl.bind("Print",                   hl.dsp.exec_cmd(screenshot .. " region"), { description = "Screenshot Region" })
hl.bind("SHIFT + Print",           hl.dsp.exec_cmd(screenshot .. " full"),   { description = "Screenshot Fullscreen" })
hl.bind("ALT + Print",             hl.dsp.exec_cmd(screenshot .. " window"), { description = "Screenshot Active Window" })
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a -n"),      { description = "Color Picker (Hex to Clipboard)" })

-- Lock & Power Menu
hl.bind(mainMod .. " + Escape",    hl.dsp.exec_cmd(powerMenu), { description = "Power Menu" })
hl.bind(mainMod .. " + X",         hl.dsp.exec_cmd(powerMenu), { description = "Power Menu" })
hl.bind(mainMod .. " + CTRL + L",  hl.dsp.exec_cmd("pidof hyprlock || hyprlock"), { description = "Lock Screen" })
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload && pkill -SIGUSR2 waybar"), { description = "Reload Config" })

-- 9. Hardware / Media Keys
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),                                 { locked = true })
hl.bind("XF86AudioPause",        hl.dsp.exec_cmd("playerctl play-pause"),                           { locked = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"),                           { locked = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),                             { locked = true })

----------------------
---- WINDOW RULES ----
----------------------
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

local floatClasses = {
    "^(org\\.pulseaudio\\.pavucontrol|pavucontrol)$",
    "^(blueman-manager)$",
    "^(nm-applet|nm-connection-editor)$",
    "^(org\\.gnome\\.Calculator|gnome-calculator)$",
    "^(qt[56]ct|nwg-look)$",
    "^(xdg-desktop-portal-gtk)$",
    "^(hyprland-share-picker)$",
}
for _, cls in ipairs(floatClasses) do
    hl.window_rule({ match = { class = cls }, float = true, center = true })
end

local floatTitles = {
    "^(Open|Open File|Save As|Confirm to replace files|File Operation Progress|Authentication Required)$",
    "^(Picture-in-Picture)$",
}
for _, ttl in ipairs(floatTitles) do
    hl.window_rule({ match = { title = ttl }, float = true })
end
