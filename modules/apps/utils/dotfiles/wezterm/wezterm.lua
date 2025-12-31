local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.skip_close_confirmation_for_processes_named = {
  'bash',
  'sh',
  'zsh',
  'fish',
  'tmux',
  'nu',
  'cmd.exe',
  'pwsh.exe',
  'powershell.exe',
  'yazi',
}

-- Visuals
config.window_background_opacity = 0.8
-- On Wayland, this often helps with blur if supported by the compositor
config.macos_window_background_blur = 20 

-- Colors (Will be injected by Magician later)
config.color_scheme = 'Catppuccin Mocha'

return config
