local awful = require("awful")
local gshape = require("gears.shape")
local wibox = require("wibox")

local server = require("sys.backlight")

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
			{
				widget = wibox.widget.textbox,
				id = "value",
				text = "00",
			}
		}
	}
})

local slider = awful.popup({
	widget = {
		widget = wibox.container.background,
		bg = "#268f28",
		{
			widget = wibox.container.margin,
			margins = 5,
			{
				layout = wibox.layout.fixed.vertical,
				spacing = 5,
				{
					widget = wibox.container.rotate,
					direction = "east",
					{
						widget = wibox.widget.slider,
						bar_height = 2, bar_width = 30,
						bar_shape = gshape.rounded_bar,
						minimum = 0, maximum = 100,
						forced_width = 100, forced_height = 2,
						value = 0,
					},
				},
				{
					widget = wibox.widget.textbox,
					id = "value",
					text = "00",
				}
			}
		}
	},
	placement = { }, -- seems optional
	ontop = true,
	visible = false,
	parent = bar_wgt, -- seems optional
})

bar_wgt:buttons(
	awful.button({ }, 1,
	function()
		awful.placement.next_to(slider, {
			preferred_positions = { "bottom" },
			preferred_anchors = { "middle" },
			mode = "cursor_inside",
			offset = { y = 5 },
		})
		slider.visible = not slider.visible
	end)
)

server:sync(function(percentage)
	bar_wgt:get_children_by_id("value")[1].text = percentage.."%"
end)

return bar_wgt
