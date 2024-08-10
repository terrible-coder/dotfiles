local awful = require("awful")
local gshape = require("gears.shape")
local gtimer = require("gears.timer")
local wibox = require("wibox")

local server = require("sys.backlight")

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
				text = "󰃟",
			},
			bar_wgt_label,
		}
	}
})

local slider = wibox.widget({
	widget = wibox.widget.slider,
	bar_height = 2, bar_width = 30,
	bar_shape = gshape.rounded_bar,
	handle_shape = gshape.rounded_rect,
	handle_width = 5,
	handle_margins = { top = 2, bottom = 2 },
	minimum = 0, maximum = 100,
	forced_width = 100, forced_height = 2,
	value = 0,
})

local text_label = wibox.widget.textbox("00")
local icon_label = wibox.widget.textbox(" 󰃟 ")

-- prevent flooding system with mutliple calls to external programmes
local slider_drag = true
slider:connect_signal("property::value", function(self)
	slider_drag = true
	text_label.text = ("%02d%%"):format(self.value)
end)

-- this trigger is fired relying solely on
-- https://github.com/awesomeWM/awesome/issues/1241#issuecomment-264109466
-- does not work in v4.3
slider:connect_signal("button::release", function()
		if not slider_drag then return end
		slider_drag = false
		server:change(slider.value - server.level)
end)

local brightness_popup = awful.popup({
	widget = {
		widget = wibox.container.background,
		bg = "#268f28",
		{
			widget = wibox.container.margin,
			margins = 5,
			{
				layout = wibox.layout.fixed.vertical,
				spacing = 5,
				icon_label,
				{
					widget = wibox.container.rotate,
					direction = "east",
					slider,
				},
				text_label
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
		awful.placement.next_to(brightness_popup, {
			preferred_positions = { "bottom" },
			preferred_anchors = { "middle" },
			mode = "cursor_inside",
			offset = { y = 5 },
		})
		brightness_popup.visible = not brightness_popup.visible
	end)
)

server:sync(function(percentage)
	slider.value = percentage
	bar_wgt_label.text = percentage.."%"
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
