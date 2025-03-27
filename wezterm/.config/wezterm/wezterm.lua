local wezterm = require("wezterm")

wezterm.on("update-right-status", function(window, _pane)
	local battery_info = ""
	for _, battery in ipairs(wezterm.battery_info()) do
		battery_info = string.format("BATTERY: %.0f%%", battery.state_of_charge * 100)
	end
	window:set_right_status(wezterm.format({ { Text = battery_info } }))
end)

return {
	-- color_scheme = "tokyonight_storm",
	-- color_scheme = "OneDark (base16)",
	-- color_scheme = "OneHalfDark",
	-- color_scheme = "3024 (base16)",
	color_scheme = "Catppuccin Frappe",
	font_size = 16,
	hide_tab_bar_if_only_one_tab = true,
	line_height = 1.2,
	-- macos_window_background_blur = 10,
	-- window_background_opacity = 0.95,
	-- font = wezterm.font("DejaVu Sans Mono"),
	-- font = wezterm.font("Bitstream Vera Sans Mono"),
	window_decorations = "RESIZE",
	window_padding = {
		top = 0,
		right = 0,
		bottom = 0, -- This will remove any bottom padding
		left = 0,
	},
}
