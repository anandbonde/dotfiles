local wezterm = require("wezterm")

wezterm.on("update-right-status", function(window, _pane)
	local battery_info = ""
	for _, battery in ipairs(wezterm.battery_info()) do
		battery_info = string.format("BATTERY: %.0f%%", battery.state_of_charge * 100)
	end
	window:set_right_status(wezterm.format({ { Text = battery_info } }))
end)

return {
	color_scheme = "tokyonight_storm",
	font_size = 16,
	hide_tab_bar_if_only_one_tab = true,
	line_height = 1.2,
	-- macos_window_background_blur = 10,
	-- window_background_opacity = 0.9,
}
