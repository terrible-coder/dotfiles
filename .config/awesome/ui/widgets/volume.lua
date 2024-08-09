local awful = require("awful")
local gshape = require("gears.shape")
local wibox = require("wibox")

local server = require("sys.sound")

local bar_wgt = wibox.widget({
	widget = wibox.container.background,
	bg = "#26288f",
	shape = function(cr, w, h) gshape.rounded_rect(cr, w, h, 2) end,
	{
		widget = wibox.container.margin,
		left = 5, right = 5, top = 2, bottom = 2,
		{
			layout = wibox.layout.fixed.horizontal,
			spacing = 5,
			{
				widget = wibox.widget.textbox,
				id = "icon",
				text = "",
			},
			{
				widget = wibox.widget.textbox,
				id = "value",
				text = "00",
			}
		}
	}
})

server:sync(function(_, volume)
	bar_wgt:get_children_by_id("value")[1].text = volume.."%"
end)

return bar_wgt
