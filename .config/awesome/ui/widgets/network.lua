local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local wibox = require("wibox")
local gshape = require("gears.shape")
local naughty = require("naughty")

local dbus = require("modules.dbus-lua")
local net_enums = require("sys.network.enums")
local wifi = require("sys").wifi

local wl_obj = wifi.object
local IFACE = {
	properties = "org.freedesktop.DBus.Properties",
	device = wifi.base..".Device",
	wireless = wifi.base..".Device.Wireless",
	access_point = wifi.base..".AccessPoint",
}
local wl_props = wl_obj:implement(IFACE.properties)
local wl_device = wl_obj:implement(IFACE.device)
local wl_wireless = wl_obj:implement(IFACE.wireless)

local icons = {
	unknown = "󰤫",
	unavailable = "󰤮",
	disconnected = "󰤯",
	connecting = "󱛏",
	activated = {
		"󰤟",
		"󰤢",
		"󰤥",
		"󰤨",
	}
}

local wgt_icon = wibox.widget.textbox(icons.unavailable)
wgt_icon.font = beautiful.fonts.nerd..16
local wgt_label = wibox.widget.textbox("WiFi")

local bar_widget = wibox.widget({
	layout = wibox.layout.fixed.horizontal,
	{
		widget = wibox.container.background,
		shape = function(cr, w, h)
			gshape.partially_rounded_rect(cr, w, h, true, false, false, true, dpi(2))
		end,
		fg = beautiful.colors.hl_low, bg = beautiful.colors.foam,
		{
			widget = wibox.container.margin,
			left = dpi(4), right = dpi(3), top = dpi(2), bottom = dpi(2),
			wgt_icon,
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
			left = dpi(7), right = dpi(5),
			wgt_label,
		}
	}
})

local _last_level = 0
local active_ap = nil
local function prepare_ap(path)
	if path == "/" then
		if active_ap then
			naughty.notify({
				title = "WiFi",
				text = ("Disconnecting from '%s'"):format(
					string.char(table.unpack(active_ap.Ssid))
				)
			})
			active_ap.on.destroy()
		end
		active_ap = nil
		return
	end
	active_ap = dbus.Proxy.new(dbus.ObjectProxy.new(
		dbus.Bus.SYSTEM, path, wl_obj.name), IFACE.access_point
	)
	naughty.notify({
		title = "WiFi",
		text = ("Connected to '%s'"):format(
			string.char(table.unpack(active_ap.Ssid))
		)
	})
	active_ap.on.PropertiesChanged(function(changed)
		if changed.Strength then
			local level = 0
			if changed.Strength > 75 then level = 4
			elseif changed.Strength > 50 then level = 3
			elseif changed.Strength > 25 then level = 2
			else level = 1
			end
			if level ~= _last_level then
				_last_level = level
				wgt_icon.text = icons.activated[level]
			end
		end
	end)
end

wl_device.on.StateChanged(function(new, old, reason)
	wgt_label.text = "WiFi"
	if new == net_enums.DeviceState.UNKNOWN then
		wgt_icon.text = icons.unknown
	elseif new == net_enums.DeviceState.UNAVAILABLE then
		wgt_icon.text = icons.unavailable
	elseif new == net_enums.DeviceState.DISCONNECTED then
		wgt_icon.text = icons.disconnected
	elseif new >= net_enums.DeviceState.PREPARE and
		     new <= net_enums.DeviceState.SECONDARIES then
		wgt_icon.text = icons.connecting
	elseif new == net_enums.DeviceState.ACTIVATED then
		wgt_icon.text = icons.activated[1]
	else
		wgt_label.text = "state: "..new
	end
end)

wl_wireless.on.PropertiesChanged(function(changed)
	if changed.ActiveAccessPoint ~= nil then
		prepare_ap(changed.ActiveAccessPoint)
	end
end)

local state = wl_device.State
wgt_label.text = "WiFi"
if state == net_enums.DeviceState.UNKNOWN then
	wgt_icon.text = icons.unknown
elseif state == net_enums.DeviceState.UNAVAILABLE then
	wgt_icon.text = icons.unavailable
elseif state == net_enums.DeviceState.DISCONNECTED then
	wgt_icon.text = icons.disconnected
elseif state >= net_enums.DeviceState.PREPARE and
	state <= net_enums.DeviceState.SECONDARIES then
	wgt_icon.text = icons.connecting
elseif state == net_enums.DeviceState.ACTIVATED then
	wgt_icon.text = icons.activated[1]
else
	wgt_label.text = "state: "..state
end
prepare_ap(wl_wireless.ActiveAccessPoint)

return bar_widget
