local Capi = {
	awesome = awesome,
}
local GLib = require("lgi").GLib
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local naughty = require("naughty")

local bluetooth = require("sys").bluetooth
local IFACE = {
	properties = "org.freedesktop.DBus.Properties",
	adapter = bluetooth.base..".Adapter1",
}
local bl_obj = bluetooth.object
local bl_adapter = bl_obj:implement(IFACE.adapter)
local bl_props = bl_obj:implement(IFACE.properties)

local icons = {
	ON = "󰂯",
	OFF = "󰂲",
	CONNECTED = "󰂱",
}

local wgt_icon = wibox.widget.textbox(
	bl_adapter.Powered and icons.ON or icons.OFF
)
wgt_icon.font = beautiful.fonts.nerd..12

local bar_widget = wibox.widget({
	widget = wibox.container.background,
	shape = beautiful.shapes.rounded_small,
	shape_border_width = dpi(1),
	shape_border_color = beautiful.colors.foam,
	{
		widget = wibox.container.margin,
		left = dpi(4), right = dpi(4), top = dpi(2), bottom = dpi(2),
		wgt_icon,
	}
})

local power_status = wibox.widget({
	widget = wibox.container.background,
	bg = beautiful.colors.iris, fg = beautiful.colors.hl_low,
	shape = beautiful.shapes.rounded_small,
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
		bl_props:GetAsync(
			function (_, powered)
				bl_props:SetAsync(
					function() end, nil,
					IFACE.adapter, "Powered", GLib.Variant.new_boolean(not powered))
			end, nil,
			IFACE.adapter, "Powered")
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
		bl_props:GetAsync(
			function (_, discoverable)
				bl_props:SetAsync(
					function() end, nil,
					IFACE.adapter, "Discoverable", GLib.Variant.new_boolean(not discoverable)
				)
			end, nil,
			IFACE.adapter, "Discoverable"
		)
	end)
)

local powered = bl_adapter.Powered
power_status.power = powered
if powered then
	bar_widget.bg = beautiful.colors.foam
	bar_widget.fg = beautiful.colors.hl_low
	discoverable_status.fg = nil
else
	bar_widget.bg = beautiful.colors.hl_low
	bar_widget.fg = beautiful.colors.foam
	discoverable_status.fg = beautiful.colors.muted
end
local discoverable = bl_adapter.Discoverable
discoverable_status.text = discoverable and "yes" or "no"

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
						bl_adapter.Name,
						bl_adapter.Address)
				},
				discoverable_status,
			}
		}
	},
	shape = beautiful.shapes.rounded_large,
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

bl_adapter.on.PropertiesChanged(function(changed)
	if changed.Powered ~= nil then
		local text = changed.Powered and "on" or "off"
		naughty.notify({
			title = "Bluetooth",
			text = "Switched " .. text
		})
		if changed.Powered then
			wgt_icon.text = icons.ON
			bar_widget.bg = beautiful.colors.foam
			bar_widget.fg = beautiful.colors.hl_low
			discoverable_status.fg = nil
		else
			wgt_icon.text = icons.OFF
			bar_widget.bg = beautiful.colors.hl_low
			bar_widget.fg = beautiful.colors.foam
			discoverable_status.fg = beautiful.colors.muted
		end
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
end)

return bar_widget
