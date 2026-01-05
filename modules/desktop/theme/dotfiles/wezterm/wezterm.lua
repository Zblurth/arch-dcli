local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- 1. Appearance (The Glass)
config.window_decorations = "NONE"
config.window_background_opacity = 0.85
config.text_background_opacity = 1.0
config.enable_tab_bar = false
config.window_close_confirmation = "NeverPrompt"
config.window_padding = {
  left = 20,
  right = 20,
  top = 20,
  bottom = 20,
}

-- 2. Font (The Vibe)
-- We assume a patched font is available.
-- Magician can patch this dynamically later, but we set a solid default.
config.font = wezterm.font_with_fallback {
  'JetBrainsMono Nerd Font',
  'Noto Sans',
  'Noto Sans Symbols',
  'Noto Sans CJK SC',
  'Noto Color Emoji',
  'Symbols Nerd Font',
}
config.font_size = 12.0
config.line_height = 1.2
config.initial_cols = 80
config.initial_rows = 35

-- 3. Integration (The Launch)
-- Automatically start Zellij (fresh session per window)
config.default_prog = { '/usr/bin/zsh', '-c', 'zellij' }

-- 4. Magician Integration (Dynamic Colors)
-- We try to load the generated file. If it fails, we fall back to a safe theme.
local success, wallet = pcall(require, 'colors-wezterm')
if success then
    config.colors = wallet.colors
else
    config.color_scheme = 'Catppuccin Mocha'
end

-- 5. Keybindings
-- We disable most Wezterm bindings so they don't conflict with Zellij
config.keys = {
    -- Safety Hatch: Shift+Ctrl+Z to open a raw shell if Zellij breaks
    {
        key = 'Z',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.SpawnCommandInNewWindow {
            args = { 'zsh' },
        },
    },
    -- Debug: Reload Config
    {
        key = 'R',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.ReloadConfiguration,
    },
}

return config
