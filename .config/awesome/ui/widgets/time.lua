local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local wibox = require("wibox")

local time_label = wibox.widget.textclock("%H:%M on (%a) %d %b, '%y")
local time_icon = wibox.widget.textbox("󰥔")
time_icon.font = beautiful.fonts.nerd..16

local bar_wgt = wibox.widget({
	layout = wibox.layout.fixed.horizontal,
	{
		widget = wibox.container.background,
		bg = beautiful.bg_focus,
		shape = beautiful.shapes.partial_rounded_left,
		{
			widget = wibox.container.margin,
			left = dpi(4), right = dpi(3), top = dpi(2), bottom = dpi(2),
			time_icon,
		}
	},
	{
		widget = wibox.container.background,
		shape = beautiful.shapes.partial_rounded_right,
		shape_border_width = dpi(1),
		shape_border_color = beautiful.bg_focus,
		{
			widget = wibox.container.margin,
			left = dpi(7), right = dpi(5),
			time_label,
		}
	}
})

return bar_wgt
