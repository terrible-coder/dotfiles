local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gshape = require("gears.shape")
local wibox = require("wibox")

local time_label = wibox.widget.textclock("%H:%M on (%a) %d %b, '%y")
local time_icon = wibox.widget.textbox("󰥔")
time_icon.font = beautiful.fonts.nerd..16

local bar_wgt = wibox.widget({
	layout = wibox.layout.fixed.horizontal,
	{
		widget = wibox.container.background,
		shape = function(cr, w, h)
			gshape.partially_rounded_rect(cr, w, h, true, false, false, true, dpi(2))
		end,
		fg = beautiful.colors.hl_low, bg = beautiful.colors.rose,
		{
			widget = wibox.container.margin,
			left = dpi(4), right = dpi(3), top = dpi(2), bottom = dpi(2),
			time_icon,
		}
	},
	{
		widget = wibox.container.background,
		bg = beautiful.colors.hl_low,
		shape = function(cr, w, h)
			gshape.partially_rounded_rect(cr, w, h, false, true, true, false, dpi(2))
		end,
		shape_border_width = dpi(1),
		shape_border_color = beautiful.colors.rose,
		{
			widget = wibox.container.margin,
			left = dpi(7), right = dpi(5),
			time_label,
		}
	}
})

return bar_wgt
