local wezterm = require("wezterm")

return {
	-- color_scheme = "Solarized Light (Gogh)",
	-- color_scheme = "Gruvbox dark, medium (base16)",
	color_scheme = "tokyonight-storm",
	font_size = 12,
	hide_tab_bar_if_only_one_tab = true,
	-- line_height = 1.2,
	-- macos_window_background_blur = 20,
	-- window_background_opacity = 0.8,
	-- font = wezterm.font("DejaVu Sans Mono"),
	window_decorations = "RESIZE",
	window_padding = {
		top = 0,
		right = 0,
		bottom = 0, -- This will remove any bottom padding
		left = 0,
	},
}
