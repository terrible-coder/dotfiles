-- local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local wibox = require("wibox")
local gshape = require("gears.shape")
local naughty = require("naughty")

local dbus = require("modules.dbus-lua")
local wifi = require("sys").wifi
local net_enums = wifi.enums

local wl_obj = wifi.object
local IFACE = {
	properties = "org.freedesktop.DBus.Properties",
	device = wifi.base..".Device",
	wireless = wifi.base..".Device.Wireless",
	access_point = wifi.base..".AccessPoint",
}
-- local wl_props = wl_obj:implement(IFACE.properties)
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

local bar_widget = wibox.widget({
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

wl_device.on.StateChanged(function(new, _, _)
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
	end
end)

wl_wireless.on.PropertiesChanged(function(changed)
	if changed.ActiveAccessPoint ~= nil then
		prepare_ap(changed.ActiveAccessPoint)
	end
end)

local state = wl_device.State
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
end
prepare_ap(wl_wireless.ActiveAccessPoint)

return bar_widget
