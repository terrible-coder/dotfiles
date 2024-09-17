local gshape = require("gears.shape")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local wgt_icon = wibox.widget.textbox("󰂯")
wgt_icon.font = beautiful.fonts.nerd..12
local wgt_label = wibox.widget.textbox("off")

local bar_widget = wibox.widget({
	layout = wibox.layout.fixed.horizontal,
	{
		widget = wibox.container.background,
		shape = function(cr, w, h)
			gshape.partially_rounded_rect(cr, w, h, true, false, false, true, dpi(2))
		end,
		fg = beautiful.colors.hl_low, bg = beautiful.colors.foam,
		{
			widget = wibox.container.margin,
			left = dpi(4), right = dpi(3), top = dpi(2), bottom = dpi(2),
			wgt_icon,
		}
	},
	{
		widget = wibox.container.background,
		bg = beautiful.colors.hl_low,
		shape = function(cr, w, h)
			gshape.partially_rounded_rect(cr, w, h, false, true, true, false, dpi(2))
		end,
		shape_border_width = dpi(1),
		shape_border_color = beautiful.colors.foam,
		{
			widget = wibox.container.margin,
			left = dpi(7), right = dpi(5),
			wgt_label,
		}
	}
})

return bar_widget
