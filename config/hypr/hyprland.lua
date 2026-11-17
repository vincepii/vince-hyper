-- ============================================================================
-- Hyprland 0.57+ Configuration (Clean Power-User + Sway/i3 Dwindle Setup)
-- ============================================================================

local home = os.getenv("HOME")
package.path = home .. "/.config/hypr/?.lua;" .. package.path

local ok, theme = pcall(require, "theme")
if not ok or type(theme) ~= "table" then
    theme = {}
end

local activeBorder        = theme.active_border          or { colors = { "rgba(7aa2f7ee)", "rgba(bb9af7ee)" }, angle = 45 }
local inactiveBorder      = theme.inactive_border        or "rgba(292e42aa)"
local groupBorderActive   = theme.group_border_active    or activeBorder
local groupBorderInactive = theme.group_border_inactive  or inactiveBorder
local groupLockedActive   = theme.group_locked_active    or { colors = { "rgba(f7768eee)", "rgba(ff9e64ee)" }, angle = 45 }
local groupLockedInactive = theme.group_locked_inactive  or inactiveBorder
local groupbarActive      = theme.groupbar_active        or "rgba(7aa2f7ee)"
local groupbarInactive    = theme.groupbar_inactive      or "rgba(292e42dd)"
local groupbarLocked      = theme.groupbar_locked_active or "rgba(f7768eee)"
local groupbarTextActive  = theme.groupbar_text_active   or "rgba(1a1b26ff)"
local groupbarTextInact   = theme.groupbar_text_inactive or "rgba(c0caf5ff)"

------------------
---- MONITORS ----
------------------
-- Optional per-machine override in ~/.config/hypr/monitors.lua (untracked, untouched by apply.sh)
local hasLocalMonitors = pcall(require, "monitors")
if not hasLocalMonitors then
    hl.monitor({
        output   = "DP-1",
        mode     = "highrr",
        position = "0x0",
        scale    = 1.25,
    })

    hl.monitor({
        output   = "",
        mode     = "preferred",
        position = "auto",
        scale    = "auto",
    })
end

---------------------
---- MY PROGRAMS ----
---------------------
local terminal     = "kitty"
local fileManager  = "nautilus --new-window"
local browser      = "flatpak run com.google.Chrome"
local launcher     = "rofi -show drun"
local windowMenu   = "rofi -show window"
local calcMenu     = "rofi -show calc"
local emojiMenu    = "rofimoji --selector rofi --action type copy"
local clipMenu     = home .. "/.local/bin/clipboard-menu"
local themeMenu    = home .. "/.local/bin/theme-switcher"
local wallMenu     = home .. "/.local/bin/wallpaper-switcher"
local powerMenu    = home .. "/.local/bin/power-menu"
local keybindMenu  = home .. "/.local/bin/keybinds-menu"
local screenshot   = home .. "/.local/bin/screenshot"
local switchLayout = home .. "/.local/bin/switch-layout"

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
hl.env("FREETYPE_PROPERTIES", "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0")
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
    -- Set 120 DPI (96 * 1.25) and unhinted grayscale AA for XWayland apps when force_zero_scaling = true
    hl.exec_cmd("printf 'Xft.dpi: 120\\nXft.antialias: 1\\nXft.hinting: 0\\nXft.hintstyle: hintnone\\nXft.rgba: none\\n' | xrdb -merge 2>/dev/null || true")
    hl.exec_cmd(themeMenu .. " --restore")
    hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("swayosd-server")
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
        no_focus_fallback   = true,
        layout              = "dwindle",
        col = {
            active_border   = activeBorder,
            inactive_border = inactiveBorder,
        },
    },

    group = {
        col = {
            border_active          = groupBorderActive,
            border_inactive        = groupBorderInactive,
            border_locked_active   = groupLockedActive,
            border_locked_inactive = groupLockedInactive,
        },
        groupbar = {
            font_family           = "JetBrainsMono Nerd Font",
            font_size             = 11,
            height                = 22,
            rounding              = 6,
            gradients             = true,
            text_color            = groupbarTextActive,
            text_color_inactive   = groupbarTextInact,
            col = {
                active          = groupbarActive,
                inactive        = groupbarInactive,
                locked_active   = groupbarLocked,
                locked_inactive = groupbarInactive,
            },
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
            xray              = false,
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

    -- Variable Frame Rate (VFR): in Hyprland 0.57+ Lua config, vfr is under debug.vfr
    debug = {
        vfr = true,
    },

    render = {
        direct_scanout = 1,
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

-- Persistent workspaces 1..5 (portable across any monitor connector: DP-1, eDP-1, HDMI-A-1)
for i = 1, 5 do
    hl.workspace_rule({ workspace = tostring(i), persistent = true })
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
        kb_options         = "caps:none",
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

-------------------------------------------------------
---- KEYBINDINGS (Standardized Sway/i3 + Dwindle)  ----
-------------------------------------------------------
local mainMod = "SUPER"

-- 1. Core Applications & Launchers
hl.bind("SUPER + SUPER_L",              hl.dsp.exec_cmd("pkill -x rofi || " .. launcher),   { release = true, description = "Toggle App Launcher on Left Super tap" })
hl.bind("SUPER + SUPER_R",              hl.dsp.exec_cmd("pkill -x rofi || " .. launcher),   { release = true, description = "Toggle App Launcher on Right Super tap" })
hl.bind(mainMod .. " + D",              hl.dsp.exec_cmd("pkill -x rofi || " .. launcher),   { non_consuming = false, description = "App Launcher" })
hl.bind(mainMod .. " + Space",          hl.dsp.exec_cmd("pkill -x rofi || " .. launcher),   { description = "App Launcher" })
hl.bind(mainMod .. " + Tab",            hl.dsp.exec_cmd("pkill -x rofi || " .. windowMenu), { description = "Window Switcher" })
hl.bind("ALT + Tab",                    hl.dsp.window.cycle_next(),                         { description = "Cycle next window" })
hl.bind(mainMod .. " + Return",         hl.dsp.exec_cmd(terminal),                          { description = "Terminal (Kitty)" })
hl.bind(mainMod .. " + B",              hl.dsp.exec_cmd(browser),                           { description = "Browser (Chrome)" })
hl.bind(mainMod .. " + E",              hl.dsp.exec_cmd(fileManager),                       { description = "File Manager (Nautilus)" })
hl.bind("CTRL + SHIFT + Escape",        hl.dsp.exec_cmd("pkill -f 'kitty --class floating-btop' || kitty --class floating-btop -e btop"), { description = "System Monitor (floating btop)" })
hl.bind(mainMod .. " + Slash",          hl.dsp.exec_cmd(keybindMenu),                       { description = "Keybind Cheat Sheet" })
hl.bind(mainMod .. " + SHIFT + Slash",  hl.dsp.exec_cmd(keybindMenu),                       { description = "Keybind Cheat Sheet" })
hl.bind(mainMod .. " + equal",          hl.dsp.exec_cmd("pkill -x rofi || " .. calcMenu),   { description = "Inline Calculator (Rofi + qalc)" })
hl.bind(mainMod .. " + period",         hl.dsp.exec_cmd("pkill -x rofi || " .. emojiMenu),  { description = "Emoji Picker (rofimoji)" })
hl.bind(mainMod .. " + V",              hl.dsp.exec_cmd(clipMenu),                          { description = "Clipboard Manager" })
hl.bind(mainMod .. " + SHIFT + T",      hl.dsp.exec_cmd(themeMenu),                         { description = "Theme Selector" })
hl.bind(mainMod .. " + CTRL + W",       hl.dsp.exec_cmd(wallMenu),                          { description = "Wallpaper Selector" })
hl.bind(mainMod .. " + N",              hl.dsp.exec_cmd("swaync-client -t -sw"),            { description = "Notification Center" })

-- 2. Window Management (Sway / i3 + Dwindle)
hl.bind(mainMod .. " + Q",              hl.dsp.window.close(),                              { description = "Close active window" })
hl.bind(mainMod .. " + SHIFT + Q",      hl.dsp.window.close(),                              { description = "Close active window" })
hl.bind(mainMod .. " + C",              hl.dsp.window.close(),                              { description = "Close active window" })
hl.bind(mainMod .. " + SHIFT + Escape", hl.dsp.release_input_capture(),                     { dont_inhibit = true, description = "Force-release VM / Remote Desktop keyboard grab" })
hl.bind(mainMod .. " + F",              hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), { description = "Toggle Fullscreen" })
hl.bind(mainMod .. " + M",              hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }),  { description = "Toggle Maximize (keep Waybar)" })
hl.bind(mainMod .. " + SHIFT + Space",  hl.dsp.window.float({ action = "toggle" }),         { description = "Toggle Floating / Tiling" })
hl.bind(mainMod .. " + P",              hl.dsp.window.pseudo(),                             { description = "Toggle Pseudo-Tile" })
hl.bind(mainMod .. " + O",              hl.dsp.layout("togglesplit"),                       { description = "Toggle Split Orientation (Dwindle)" })
hl.bind(mainMod .. " + Backslash",      hl.dsp.layout("togglesplit"),                       { description = "Toggle Split Orientation (Dwindle)" })

-- 3. Tabbed Window Groups (Super + W)
hl.bind(mainMod .. " + W",              hl.dsp.group.toggle(),                              { description = "Toggle Tabbed Window Group" })
hl.bind(mainMod .. " + SHIFT + W",      hl.dsp.window.move({ out_of_group = true }),        { description = "Move Active Window Out of Group" })
hl.bind(mainMod .. " + ALT + H",        hl.dsp.group.prev(),                                { description = "Previous Window Tab in Group" })
hl.bind(mainMod .. " + ALT + left",     hl.dsp.group.prev(),                                { description = "Previous Window Tab in Group" })
hl.bind(mainMod .. " + ALT + L",        hl.dsp.group.next(),                                { description = "Next Window Tab in Group" })
hl.bind(mainMod .. " + ALT + right",    hl.dsp.group.next(),                                { description = "Next Window Tab in Group" })

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

-- 6. Resize Windows (40px steps): Super + Ctrl + H/J/K/L and Arrow Keys
hl.bind(mainMod .. " + CTRL + H",     hl.dsp.window.resize({ x = -40, y = 0,   relative = true }), { repeating = true, description = "Resize narrower" })
hl.bind(mainMod .. " + CTRL + L",     hl.dsp.window.resize({ x = 40,  y = 0,   relative = true }), { repeating = true, description = "Resize wider" })
hl.bind(mainMod .. " + CTRL + K",     hl.dsp.window.resize({ x = 0,   y = -40, relative = true }), { repeating = true, description = "Resize shorter" })
hl.bind(mainMod .. " + CTRL + J",     hl.dsp.window.resize({ x = 0,   y = 40,  relative = true }), { repeating = true, description = "Resize taller" })
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.resize({ x = -40, y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 40,  y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.resize({ x = 0,   y = -40, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.resize({ x = 0,   y = 40,  relative = true }), { repeating = true })

-- Mouse Drag & Resize
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- 7. Workspaces 1..10 & Scratchpad
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }),                       { description = "Switch to workspace " .. i })
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }),                 { description = "Move window to workspace " .. i })
    hl.bind(mainMod .. " + CTRL + " .. key,  hl.dsp.window.move({ workspace = i, follow = false }), { description = "Move window silently to workspace " .. i })
end

-- Cycle Previous / Next Workspaces: Super + [ / ] and Mouse Scroll
hl.bind(mainMod .. " + bracketleft",  hl.dsp.focus({ workspace = "e-1" }), { description = "Previous Workspace" })
hl.bind(mainMod .. " + bracketright", hl.dsp.focus({ workspace = "e+1" }), { description = "Next Workspace" })
hl.bind(mainMod .. " + mouse_up",     hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse_down",   hl.dsp.focus({ workspace = "e+1" }))

-- Scratchpad (Special Workspace): Super + minus (-) and Super + S
hl.bind(mainMod .. " + minus",         hl.dsp.workspace.toggle_special("scratchpad"),          { description = "Toggle Scratchpad" })
hl.bind(mainMod .. " + S",             hl.dsp.workspace.toggle_special("scratchpad"),          { description = "Toggle Scratchpad" })
hl.bind(mainMod .. " + SHIFT + minus", hl.dsp.window.move({ workspace = "special:scratchpad" }), { description = "Move Window to Scratchpad" })

-- 8. Screenshots & Color Picker
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(screenshot .. " region"), { description = "Screenshot Region -> Clipboard" })
hl.bind("Print",                   hl.dsp.exec_cmd(screenshot .. " region"), { description = "Screenshot Region -> Clipboard" })
hl.bind(mainMod .. " + CTRL + S",  hl.dsp.exec_cmd(screenshot .. " edit"),   { description = "Screenshot Region -> Annotate/Edit (satty)" })
hl.bind("SHIFT + Print",           hl.dsp.exec_cmd(screenshot .. " edit"),   { description = "Screenshot Region -> Annotate/Edit (satty)" })
hl.bind(mainMod .. " + Print",     hl.dsp.exec_cmd(screenshot .. " edit"),   { description = "Screenshot Region -> Annotate/Edit (satty)" })
hl.bind(mainMod .. " + ALT + S",   hl.dsp.exec_cmd(screenshot .. " full"),   { description = "Screenshot Fullscreen -> Clipboard" })
hl.bind("CTRL + Print",            hl.dsp.exec_cmd(screenshot .. " full"),   { description = "Screenshot Fullscreen -> Clipboard" })
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a -n"),      { description = "Color Picker (Hex to Clipboard)" })

-- 9. Input, Session, Lock & Bar
hl.bind("code:66",                   hl.dsp.exec_cmd(switchLayout),                    { description = "Switch Keyboard Layout (US <-> IT)" })
hl.bind(mainMod .. " + CTRL + Space", hl.dsp.exec_cmd(switchLayout),                   { description = "Switch Keyboard Layout (US <-> IT)" })
hl.bind("CTRL + ALT + L",            hl.dsp.exec_cmd("pidof hyprlock || hyprlock"),    { description = "Lock Screen" })
hl.bind(mainMod .. " + Escape",      hl.dsp.exec_cmd("pidof hyprlock || hyprlock"),    { description = "Lock Screen" })
hl.bind(mainMod .. " + SHIFT + E",   hl.dsp.exec_cmd(powerMenu),                       { description = "Power / Logout Menu" })
hl.bind(mainMod .. " + SHIFT + B",   hl.dsp.exec_cmd("pkill -x waybar; waybar"),       { description = "Restart Waybar" })
hl.bind(mainMod .. " + SHIFT + R",   hl.dsp.exec_cmd("hyprctl reload && pkill -SIGUSR2 waybar"), { description = "Reload Hyprland + Waybar" })

-- 10. Multimedia & Hardware Keys (SwayOSD On-Screen Display with wpctl/brightnessctl/playerctl fallback)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("swayosd-client --output-volume +5 --max-volume 100 || wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("swayosd-client --output-volume -5 || wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),                   { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle || wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),          { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle || wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),         { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("swayosd-client --brightness +5 || brightnessctl -e4 -n2 set 5%+"),                                   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness -5 || brightnessctl -e4 -n2 set 5%-"),                                   { locked = true, repeating = true })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("swayosd-client --playerctl next || playerctl next"),                                                 { locked = true })
hl.bind("XF86AudioPause",        hl.dsp.exec_cmd("swayosd-client --playerctl play-pause || playerctl play-pause"),                                     { locked = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("swayosd-client --playerctl play-pause || playerctl play-pause"),                                     { locked = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("swayosd-client --playerctl previous || playerctl previous"),                                         { locked = true })

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

-- Fullscreen apps (videos, games) automatically inhibit hypridle
hl.window_rule({
    name         = "fullscreen-idle-inhibit",
    match        = { fullscreen = true },
    idle_inhibit = "always",
})

-- Tiled browser video calls (Google Meet, Zoom, Microsoft Teams, Webex, Jitsi) inhibit idle when focused
hl.window_rule({
    name         = "videocall-idle-inhibit",
    match        = { title = ".*(Meet - |Google Meet|Zoom Meeting|Zoom Workplace|Microsoft Teams|Webex|Jitsi Meet|Slack \\| Huddle).*" },
    idle_inhibit = "focus",
})

-- Floating btop toggle from Waybar CPU / Memory pills
hl.window_rule({
    name   = "floating-btop",
    match  = { class = "^(floating-btop)$" },
    float  = true,
    center = true,
    size   = "1100 720",
})

-- Picture-in-Picture video overlay: floating, pinned, aspect-locked in bottom-right corner
hl.window_rule({
    name              = "picture-in-picture",
    match             = { title = "^([Pp]icture[- ]in[- ][Pp]icture)$" },
    float             = true,
    pin               = true,
    keep_aspect_ratio = true,
    size              = "480 270",
    move              = "monitor_w-window_w-20 monitor_h-window_h-20",
})

local floatClasses = {
    "^(org\\.pulseaudio\\.pavucontrol|pavucontrol)$",
    "^(blueman-manager)$",
    "^(nm-applet|nm-connection-editor)$",
    "^(org\\.gnome\\.Calculator|gnome-calculator)$",
    "^(org\\.gnome\\.Calendar|gnome-calendar)$",
    "^(qt[56]ct|nwg-look)$",
    "^(xdg-desktop-portal-gtk)$",
    "^(hyprland-share-picker)$",
}
for _, cls in ipairs(floatClasses) do
    hl.window_rule({ match = { class = cls }, float = true, center = true })
end

-- Authentication / Polkit / Pinentry dialogs: always float, center, dim background, and keep keyboard focus
local authClasses = {
    "^(hyprpolkitagent)$",
    "^(polkit-gnome-authentication-agent-1)$",
    "^(org\\.kde\\.polkit-kde-authentication-agent-1)$",
    "^(pinentry-.*)$",
    "^(gcr-prompter)$",
}
for _, cls in ipairs(authClasses) do
    hl.window_rule({
        match        = { class = cls },
        float        = true,
        center       = true,
        stay_focused = true,
        pin          = true,
        dim_around   = true,
    })
end

hl.window_rule({
    match        = { title = "^(Authentication Required|Authenticate|Unlock Keyring|Enter Password.*)$" },
    float        = true,
    center       = true,
    stay_focused = true,
    pin          = true,
    dim_around   = true,
})

local floatTitles = {
    "^(Open|Open File|Save As|Confirm to replace files|File Operation Progress)$",
}
for _, ttl in ipairs(floatTitles) do
    hl.window_rule({ match = { title = ttl }, float = true })
end

---------------------
---- LAYER RULES ----
---------------------
-- Frosted-glass compositor blur behind translucent Waybar, Rofi, SwayNC, and SwayOSD surfaces
local blurLayers = {
    "^(waybar)$",
    "^(rofi)$",
    "^(swaync-control-center)$",
    "^(swaync-notification-window)$",
    "^(swayosd)$",
}
for _, ns in ipairs(blurLayers) do
    hl.layer_rule({
        match        = { namespace = ns },
        blur         = true,
        ignore_alpha = 0.5,
    })
end
