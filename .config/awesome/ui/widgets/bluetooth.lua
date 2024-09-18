local Capi = {
	awesome = awesome,
}
local GLib = require("lgi").GLib
local awful = require("awful")
local gshape = require("gears.shape")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local naughty = require("naughty")

local bluetooth = require("sys.bluetooth")

local icons = {
	ON = "󰂯",
	OFF = "󰂲",
	CONNECTED = "󰂱",
}

local wgt_icon = wibox.widget.textbox(
	bluetooth:Get("org.bluez.Adapter1", "Powered") and icons.ON or icons.OFF
)
wgt_icon.font = beautiful.fonts.nerd..12

local bar_widget = wibox.widget({
	widget = wibox.container.background,
	shape = function(cr, w, h) gshape.rounded_rect(cr, w, h, dpi(2)) end,
	fg = beautiful.colors.hl_low, bg = beautiful.colors.foam,
	{
		widget = wibox.container.margin,
		left = dpi(5), right = dpi(5), top = dpi(2), bottom = dpi(2),
		wgt_icon,
	}
})

local power_status = wibox.widget({
	widget = wibox.container.background,
	bg = beautiful.colors.iris, fg = beautiful.colors.hl_low,
	shape = function(cr, w, h) gshape.rounded_rect(cr, w, h, 2) end,
	{
		widget = wibox.container.margin,
		left = dpi(5), right = dpi(5), top = dpi(2), bottom = dpi(2),
		{
			widget = wibox.widget.textbox,
			font = beautiful.fonts.nerd..12,
			text = "󰐥",
		}
	},
	set_power = function(self, powered)
		self.bg = powered and beautiful.colors.love or beautiful.colors.pine
	end
})
power_status:buttons(
	awful.button({ }, 1, function()
		local iface = "org.bluez.Adapter1"
		bluetooth:GetAsync(
			function (_, _, powered)
				bluetooth:SetAsync(
					function() end, nil,
					iface, "Powered", GLib.Variant.new_boolean(not powered))
			end, nil,
			iface, "Powered")
	end)
)

local discoverable_status = wibox.widget({
	widget = wibox.container.background,
	{
		widget = wibox.container.margin,
		left = dpi(5), right = dpi(5), top = dpi(2), bottom = dpi(2),
		{
			widget = wibox.widget.textbox, id = "discoverable",
		}
	},
	set_text = function(self, text)
		self:get_children_by_id("discoverable")[1].text = "Discoverable: "..text
	end
})
discoverable_status:buttons(
	awful.button({ }, 1, function()
		local iface = "org.bluez.Adapter1"
		bluetooth:GetAsync(
			function (proxy, _, discoverable)
				proxy:SetAsync(
					function() end, nil,
					iface, "Discoverable", GLib.Variant.new_boolean(not discoverable)
				)
			end, nil,
			iface, "Discoverable"
		)
	end)
)

bluetooth:GetAsync(
	function(_, _, powered)
		power_status.power = powered
	end, nil, "org.bluez.Adapter1", "Powered"
)
bluetooth:GetAsync(
	function(_, _, discoverable)
		local text = discoverable and "yes" or "no"
		discoverable_status.text = text
	end, nil, "org.bluez.Adapter1", "Discoverable"
)

local blue_popup = awful.popup({
	widget = {
		widget = wibox.container.background,
		bg = beautiful.colors.overlay,
		{
			widget = wibox.container.margin,
			margins = dpi(10),
			{
				layout = wibox.layout.fixed.vertical,
				spacing = dpi(5),
				{
					layout = wibox.layout.align.horizontal,
					{
						widget = wibox.widget.textbox,
						markup = "<b>Bluetooth</b>",
					},
					nil,
					power_status
				},
				{
					widget = wibox.widget.textbox,
					text = string.format("%s (%s)",
						bluetooth:Get("org.bluez.Adapter1", "Name"),
						bluetooth:Get("org.bluez.Adapter1", "Address"))
				},
				discoverable_status,
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

blue_popup.uid = 202

bar_widget:buttons(
	awful.button({ }, 1, function()
		Capi.awesome.emit_signal("popup_show", blue_popup.uid)
	end)
)

Capi.awesome.connect_signal("popup_show", function(uid)
	if uid == blue_popup.uid then
		blue_popup.visible = not blue_popup.visible
	else
		blue_popup.visible = false
		return
	end
	if not blue_popup.visible then return end
	awful.placement.next_to(blue_popup, {
		preferred_positions = { "bottom" },
		preferred_anchors = { "middle" },
		mode = "cursor_inside",
		offset = { y = 5 },
	})
end)

bluetooth:connect_signal(function(_, _, changed)
	if changed.Powered ~= nil then
		local text = changed.Powered and "on" or "off"
		naughty.notify({
			title = "Bluetooth",
			text = "Switched " .. text
		})
		wgt_icon.text = changed.Powered and icons.ON or icons.OFF
		power_status.power = changed.Powered
	end

	if changed.Discoverable ~= nil then
		local text = changed.Discoverable and "yes" or "no"
		local is_visible = changed.Discoverable and "Visible" or "No longer visible"
		naughty.notify({
			title = "Bluetooth",
			text = is_visible .. " to nearby devices"
		})
		discoverable_status.text = text
	end
end, "PropertiesChanged")

return bar_widget
