local Capi = {
	awesome = awesome
}
local awful = require("awful")
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
	shape = function(cr, w, h) gshape.rounded_rect(cr, w, h, dpi(2)) end,
	shape_border_width = dpi(1),
	shape_border_color = beautiful.colors.foam,
	{
		widget = wibox.container.margin,
		left = dpi(4), right = dpi(4), top = dpi(2), bottom = dpi(2),
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

local radio_status = wibox.widget({
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
	set_radio = function(self, radio)
		self.bg = radio and beautiful.colors.love or beautiful.colors.pine
	end
})

local conn_label = wibox.widget.textbox("Connection name")
local conn_recieve = wibox.widget.textbox("0 MB/s")
local conn_transfer = wibox.widget.textbox("0 MB/s")

local wifi_popup = awful.popup({
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
						markup = "<b>WiFi</b>",
					},
					nil,
					radio_status
				},
				conn_label,
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = dpi(5),
					{
						widget = wibox.widget.textbox,
						text = "󰬬",
						font = beautiful.fonts.nerd..12
					},
					conn_transfer,
				},
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = dpi(5),
					{
						widget = wibox.widget.textbox,
						text = "󰬦",
						font = beautiful.fonts.nerd..12
					},
					conn_recieve,
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

wifi_popup.uid = 230

bar_widget:buttons(
	awful.button({ }, 1, function()
		Capi.awesome.emit_signal("popup_show", wifi_popup.uid)
	end)
)

Capi.awesome.connect_signal("popup_show", function(uid)
	if uid == wifi_popup.uid then
		wifi_popup.visible = not wifi_popup.visible
	else
		wifi_popup.visible = false
		return
	end
	if not wifi_popup.visible then return end
	awful.placement.next_to(wifi_popup, {
		preferred_positions = { "bottom" },
		preferred_anchors = { "middle" },
		mode = "cursor_inside",
		offset = { y = 5 },
	})
end)

wl_device.on.StateChanged(function(new, _, _)
	if new == net_enums.DeviceState.UNKNOWN then
		wgt_icon.text = icons.unknown
		bar_widget.bg = beautiful.colors.hl_low
		bar_widget.fg = beautiful.colors.foam
	elseif new == net_enums.DeviceState.UNAVAILABLE then
		wgt_icon.text = icons.unavailable
		bar_widget.bg = beautiful.colors.hl_low
		bar_widget.fg = beautiful.colors.foam
	elseif new == net_enums.DeviceState.DISCONNECTED then
		wgt_icon.text = icons.disconnected
		bar_widget.bg = beautiful.colors.hl_low
		bar_widget.fg = beautiful.colors.foam
	elseif new >= net_enums.DeviceState.PREPARE and
		     new <= net_enums.DeviceState.SECONDARIES then
		wgt_icon.text = icons.connecting
		bar_widget.bg = beautiful.colors.foam
		bar_widget.fg = beautiful.colors.hl_low
	elseif new == net_enums.DeviceState.ACTIVATED then
		wgt_icon.text = icons.activated[1]
		bar_widget.bg = beautiful.colors.foam
		bar_widget.fg = beautiful.colors.hl_low
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
	bar_widget.bg = beautiful.colors.hl_low
	bar_widget.fg = beautiful.colors.foam
elseif state == net_enums.DeviceState.UNAVAILABLE then
	wgt_icon.text = icons.unavailable
	bar_widget.bg = beautiful.colors.hl_low
	bar_widget.fg = beautiful.colors.foam
elseif state == net_enums.DeviceState.DISCONNECTED then
	wgt_icon.text = icons.disconnected
	bar_widget.bg = beautiful.colors.hl_low
	bar_widget.fg = beautiful.colors.foam
elseif state >= net_enums.DeviceState.PREPARE and
	state <= net_enums.DeviceState.SECONDARIES then
	wgt_icon.text = icons.connecting
	bar_widget.bg = beautiful.colors.foam
	bar_widget.fg = beautiful.colors.hl_low
elseif state == net_enums.DeviceState.ACTIVATED then
	wgt_icon.text = icons.activated[1]
	bar_widget.bg = beautiful.colors.foam
	bar_widget.fg = beautiful.colors.hl_low
end
prepare_ap(wl_wireless.ActiveAccessPoint)

return bar_widget
