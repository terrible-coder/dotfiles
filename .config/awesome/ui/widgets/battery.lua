local Capi = {
	awesome = awesome,
}
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gshape = require("gears.shape")
local gmath = require("gears.math")
local wibox = require("wibox")

local server = require("sys.battery")

local icons = {
	"󰂎",
	"󰁺",
	"󰁻",
	"󰁼",
	"󰁽",
	"󰁾",
	"󰁿",
	"󰂀",
	"󰂁",
	"󰂂",
	"󰁹",
}

local text_label = wibox.widget.textbox("00")
local icon_label = wibox.widget.textbox("")
icon_label.font = beautiful.fonts.nerd..10

local bar_wgt = wibox.widget({
	layout = wibox.layout.fixed.horizontal,
	{
		widget = wibox.container.background,
		shape = function(cr, w, h)
			gshape.partially_rounded_rect(cr, w, h, true, false, false, true, dpi(2))
		end,
		fg = beautiful.colors.text, bg = beautiful.colors.pine,
		{
			widget = wibox.container.margin,
			left = dpi(4), right = dpi(3), top = dpi(2), bottom = dpi(2),
			icon_label,
		}
	},
	{
		widget = wibox.container.background,
		bg = beautiful.colors.hl_low,
		shape = function(cr, w, h)
			gshape.partially_rounded_rect(cr, w, h, false, true, true, false, dpi(2))
		end,
		shape_border_width = dpi(1),
		shape_border_color = beautiful.colors.pine,
		{
			widget = wibox.container.margin,
			left = dpi(7), right = dpi(5),
			text_label,
		}
	}
})

local popup_level = wibox.widget.textbox("00")
local popup_waiting = wibox.widget.textbox("00:00:00")
local popup_health = wibox.widget.textbox("00")

local battery_popup = awful.popup({
	widget = {
		widget = wibox.container.background,
		bg = beautiful.colors.overlay,
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
	border_width = dpi(2),
	border_color = beautiful.colors.iris,
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

local _last_icon_level = 0
server:connect_signal("battery::update", function(self)
	text_label.text = self.level
	popup_level.text = self.level.."%"
	popup_waiting.text = self.waiting
	local icon_level = gmath.round(self.level / 10) + 1
	if icon_level ~= _last_icon_level then
		_last_icon_level = icon_level
		icon_label.text = icons[icon_level]
	end
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
