local gshape = require("gears.shape")
local wibox = require("wibox")

local server = require("sys.battery")

local text_label = wibox.widget.textbox("00")
local icon_label = wibox.widget.textbox("")

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
			icon_label, text_label,
		}
	}
})

server:sync(function(mode, level, charging)
	text_label.text = level.."%"
end)

return bar_wgt
