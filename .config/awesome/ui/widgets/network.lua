local awful = require("awful")
local gshape = require("gears.shape")
local gtimer = require("gears.timer")
local wibox = require("wibox")

local server = require("sys.network")

local bar_wgt_label = wibox.widget.textbox("00")
bar_wgt_label.visible = false

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
				text = "",
			},
			bar_wgt_label,
		}
	}
})

local net_popup = awful.popup({
	widget = {
		widget = wibox.container.background,
		bg = "#268f28",
		{
			widget = wibox.container.margin,
			margins = 5,
			{
				widget = wibox.widget.textbox,
				text = "SSID"
			}
		}
	},
	placement = { },
	ontop = true,
	visible = false,
})

bar_wgt:buttons(
	awful.button({ }, 1,
	function()
		awful.placement.next_to(net_popup, {
			preferred_positions = { "bottom" },
			preferred_anchors = { "middle" },
			mode = "cursor_inside",
			offset = { y = 5 },
		})
		net_popup.visible = not net_popup.visible
	end)
)

server:sync(function(conn)
	bar_wgt_label.text = conn.ssid
	bar_wgt_label.visible = true
	gtimer({
		callback = function()
			bar_wgt_label.visible = false
		end,
		single_shot = true,
		call_now = false,
		autostart = true,
		timeout = 2,
	})
end)

return bar_wgt
