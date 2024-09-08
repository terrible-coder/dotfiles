local Capi = {
	awesome = awesome,
}
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gshape = require("gears.shape")
local wibox = require("wibox")

local server = require("sys.backlight")

local bar_wgt_label = wibox.widget.textbox("00")
local bar_wgt_icon = wibox.widget.textbox("󰃟")
bar_wgt_icon.font = beautiful.fonts.nerd..16

local bar_wgt = wibox.widget({
	layout = wibox.layout.fixed.horizontal,
	-- spacing = 5,
	{
		widget = wibox.container.background,
		shape = function(cr, w, h)
			gshape.partially_rounded_rect(cr, w, h, true, false, false, true, dpi(2))
		end,
		fg = beautiful.colors.hl_low, bg = beautiful.colors.foam,
		{
			widget = wibox.container.margin,
			left = dpi(5), right = dpi(5), top = dpi(2), bottom = dpi(2),
			bar_wgt_icon,
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
			left = dpi(10), right = dpi(5),
			bar_wgt_label,
		}
	}
})

local slider = wibox.widget({
	widget = wibox.widget.slider,
	bar_height = dpi(2), bar_width = dpi(30),
	bar_shape = gshape.rounded_bar,
	handle_shape = function(cr, _, h) gshape.rounded_rect(cr, h, h, 2) end,
	handle_width = dpi(5),
	handle_margins = { top = dpi(2), bottom = dpi(2), left = dpi(2), right = dpi(2) },
	handle_color = beautiful.colors.iris,
	minimum = 0, maximum = 100,
	forced_width = dpi(120), forced_height = dpi(5),
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
		bg = beautiful.colors.overlay,
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
	shape = function(cr, w, h) gshape.rounded_rect(cr, w, h, 5) end,
	border_width = dpi(2),
	border_color = beautiful.colors.iris,
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
