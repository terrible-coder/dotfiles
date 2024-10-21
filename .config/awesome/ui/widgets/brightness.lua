local Capi = {
	awesome = awesome,
}
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local wibox = require("wibox")

local server = require("sys.backlight")

local bar_wgt_label = wibox.widget.textbox("00")
local bar_wgt_icon = wibox.widget.textbox("󰃟")
bar_wgt_icon.font = beautiful.fonts.nerd..16

local bar_wgt = wibox.widget({
	layout = wibox.layout.fixed.horizontal,
	{
		widget = wibox.container.background,
		shape = beautiful.shapes.partial_rounded_left,
		fg = beautiful.widget_active_fg, bg = beautiful.widget_active_bg,
		{
			widget = wibox.container.margin,
			left = dpi(4), right = dpi(3), top = dpi(2), bottom = dpi(2),
			bar_wgt_icon,
		}
	},
	{
		widget = wibox.container.background,
		shape = beautiful.shapes.partial_rounded_right,
		shape_border_width = dpi(1),
		shape_border_color = beautiful.widget_active_bg,
		{
			widget = wibox.container.margin,
			left = dpi(7), right = dpi(5),
			bar_wgt_label,
		}
	}
})

local slider = wibox.widget({
	widget = wibox.widget.slider,
	bar_height = dpi(2), bar_width = dpi(30),
	bar_shape = beautiful.shapes.bar,
	handle_shape = beautiful.shapes.rounded_small,
	handle_width = dpi(10),
	handle_margins = { top = dpi(2), bottom = dpi(2) },
	minimum = 0, maximum = 100,
	forced_width = dpi(120), forced_height = dpi(15),
	value = 0,
})

local text_label = wibox.widget.textbox("00")

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
		bg = beautiful.popup_bg,
		{
			widget = wibox.container.margin,
			top = 10, bottom = 10, left = 15, right = 15,
			{
				layout = wibox.layout.fixed.vertical,
				spacing = 5,
				{
					widget = wibox.widget.textbox,
					text = "Brightness",
				},
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = 10,
					slider,
					text_label
				}
			}
		}
	},
	shape = beautiful.shapes.rounded_large,
	border_width = beautiful.popup_border_width,
	border_color = beautiful.popup_border_color,
	placement = { },
	ontop = true,
	visible = false,
})

brightness_popup.uid = 218

bar_wgt:buttons(
	awful.button({ }, 1,
	function()
		Capi.awesome.emit_signal("popup_show", brightness_popup.uid)
	end)
)

Capi.awesome.connect_signal("popup_show", function(uid)
	if uid == brightness_popup.uid then
		brightness_popup.visible = not brightness_popup.visible
	else
		brightness_popup.visible = false
	end
	if not brightness_popup.visible then return end
	awful.placement.next_to(brightness_popup, {
		preferred_positions = { "bottom" },
		preferred_anchors = { "middle" },
		mode = "cursor_inside",
		offset = { y = 5 },
	})
end)

server:connect_signal("backlight::update", function(self)
	slider.value = self.level
	bar_wgt_label.text = self.level
end)

return bar_wgt
