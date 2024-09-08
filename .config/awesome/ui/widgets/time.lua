local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gshape = require("gears.shape")
local wibox = require("wibox")

local date_label = wibox.widget.textclock("%Y, %b %d (%A)")
local date_icon = wibox.widget.textbox("󰃭")
date_icon.font = beautiful.fonts.nerd..16

local time_label = wibox.widget.textclock("%H:%M")
local time_icon = wibox.widget.textbox("󰥔")
time_icon.font = beautiful.fonts.nerd..16

local status = "time"

local bar_wgt = wibox.widget({
	layout = wibox.layout.fixed.horizontal,
	{
		widget = wibox.container.background, id = "icon_role",
		shape = function(cr, w, h)
			gshape.partially_rounded_rect(cr, w, h, true, false, false, true, dpi(2))
		end,
		fg = beautiful.colors.hl_low, bg = beautiful.colors.rose,
		{
			widget = wibox.container.margin,
			left = dpi(5), right = dpi(5), top = dpi(2), bottom = dpi(2),
			time_icon,
		}
	},
	{
		widget = wibox.container.background, id = "text_role",
		bg = beautiful.colors.hl_low,
		shape = function(cr, w, h)
			gshape.partially_rounded_rect(cr, w, h, false, true, true, false, dpi(2))
		end,
		shape_border_width = dpi(1),
		shape_border_color = beautiful.colors.rose,
		{
			widget = wibox.container.margin,
			left = dpi(10), right = dpi(5),
			time_label,
		}
	}
})

bar_wgt:connect_signal("button::press", function(_, _, _, button)
	if button == 1 then
		if status == "time" then
			bar_wgt:get_children_by_id("icon_role")[1].children[1].widget = date_icon
			bar_wgt:get_children_by_id("text_role")[1].children[1].widget = date_label
			status = "date"
		elseif status == "date" then
			bar_wgt:get_children_by_id("icon_role")[1].children[1].widget = time_icon
			bar_wgt:get_children_by_id("text_role")[1].children[1].widget = time_label
			status = "time"
		end
	end
end)

return bar_wgt
