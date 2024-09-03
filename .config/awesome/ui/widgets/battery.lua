local Capi = {
	awesome = awesome,
}
local awful = require("awful")
local beautiful = require("beautiful")
local gshape = require("gears.shape")
local wibox = require("wibox")

local server = require("sys.battery")

local text_label = wibox.widget.textbox("00")
local icon_label = wibox.widget.textbox("")
icon_label.font = beautiful.fonts.nerd..16

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
local popup_health = wibox.widget.textbox("00")

local battery_popup = awful.popup({
	widget = {
		widget = wibox.container.background,
		bg = "#268f28",
		{
			widget = wibox.container.margin,
			margins = 10,
			{
				layout = wibox.layout.fixed.vertical,
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = 20,
					popup_level, popup_waiting,
				},
				popup_health,
			}
		}
	},
	shape = function(cr, w, h) gshape.rounded_rect(cr, w, h, 5) end,
	placement = { },
	ontop = true,
	visible = false
})

battery_popup.uid = 200

bar_wgt:buttons(
	awful.button({ }, 1,
	function()
		Capi.awesome.emit_signal("popup_show", battery_popup.uid)
	end)
)

Capi.awesome.connect_signal("popup_show", function(uid)
	if uid == battery_popup.uid then
		battery_popup.visible = not battery_popup.visible
	else
		battery_popup.visible = false
	end
	if not battery_popup.visible then return end
	awful.placement.next_to(battery_popup, {
		preferred_positions = { "bottom" },
		preferred_anchors = { "middle" },
		mode = "cursor_inside",
		offset = { y = 5 },
	})
end)

server:connect_signal("battery::update", function(self)
	text_label.text = self.level
	popup_level.text = self.level.."%"
	popup_waiting.text = self.waiting
	local health_indicator = ""
	if self.health > 80 then
		health_indicator = "  "
	elseif self.health > 65 then
		health_indicator = "  "
	elseif self.health > 50 then
		health_indicator = "  "
	else
		health_indicator = "  "
	end
	popup_health.text = self.health.."% ("..health_indicator..")"
end)

return bar_wgt
