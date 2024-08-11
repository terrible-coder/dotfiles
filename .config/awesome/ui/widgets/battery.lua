local awful = require("awful")
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

local popup_level = wibox.widget.textbox("00")
local popup_waiting = wibox.widget.textbox("00:00:00")

local battery_popup = awful.popup({
	widget = {
		widget = wibox.container.background,
		bg = "#268f28",
		{
			widget = wibox.container.margin,
			margins = 10,
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = 20,
				popup_level, popup_waiting,
			}
		}
	},
	shape = function(cr, w, h) gshape.rounded_rect(cr, w, h, 5) end,
	placement = { },
	ontop = true,
	visible = false
})

bar_wgt:buttons(
	awful.button({ }, 1,
	function()
		awful.placement.next_to(battery_popup, {
			preferred_positions = { "bottom" },
			preferred_anchors = { "middle" },
			mode = "cursor_inside",
			offset = { y = 5 },
		})
		battery_popup.visible = not battery_popup.visible
	end)
)

server:sync(function(mode, level, charging)
	text_label.text = level.."%"
	popup_level.text = level.."%"
	popup_waiting.text = server.waiting
end)

return bar_wgt
