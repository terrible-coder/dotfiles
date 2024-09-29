local Capi = {
	awesome = awesome
}
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local wibox = require("wibox")
local gshape = require("gears.shape")
local gmath = require("gears.math")
local naughty = require("naughty")

local GLib = require("lgi").GLib
local dbus = require("modules.dbus-lua")
local wifi = require("sys").wifi
local net_enums = wifi.enums

local wl_obj = wifi.object
local IFACE = {
	properties = "org.freedesktop.DBus.Properties",
	device = wifi.base..".Device",
	wireless = wifi.base..".Device.Wireless",
	access_point = wifi.base..".AccessPoint",
	statistics = wifi.base..".Device.Statistics",
}
local wl_props = wl_obj:implement(IFACE.properties)
local wl_device = wl_obj:implement(IFACE.device)
local wl_wireless = wl_obj:implement(IFACE.wireless)
local wl_stats = wl_obj:implement(IFACE.statistics)

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

local partial = {
	left = function(cr, w, h)
		gshape.partially_rounded_rect(cr, w, h, true, false, false, true, dpi(2))
	end,
	right = function(cr, w, h)
		gshape.partially_rounded_rect(cr, w, h, false, true, true, false, dpi(2))
	end
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

local function state_updated(new, _, _)
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
end

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

local _received    = { bytes = 0, time = 0 }
local _transferred = { bytes = 0, time = 0 }
local function exchange_rate(bytes_now, type)
	local units = { "B/s", "KB/s", "MB/s", "GB/s" }
	local obj = nil
	if type == "recv" then obj = _received
	elseif type == "tran" then obj = _transferred
	end
	if not obj then
		error("Incorrect exchange type. Expected 'recv' or 'tran'")
	end
	if obj.time == 0 then
		obj.time = os.time()
		obj.bytes = bytes_now
		return "0 B/s"
	else
		local time_now = os.time()
		local d_bytes = bytes_now - obj.bytes
		local d_time = time_now - obj.time
		obj.bytes = bytes_now
		obj.time = time_now
		local xx_rate = d_bytes / d_time
		local x_unit = 1
		while xx_rate > 1024 do
			xx_rate = xx_rate / 1024
			x_unit = x_unit + 1
		end
		xx_rate = gmath.round(xx_rate)
		return tostring(xx_rate).." "..units[x_unit]
	end
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

local conn_label = wibox.widget({
	widget = wibox.container.background,
	bg = beautiful.colors.iris, fg = beautiful.colors.hl_low,
	shape = partial.left,
	{
		widget = wibox.container.margin,
		left = dpi(5), right = dpi(5), top = dpi(2), bottom = dpi(2),
		{
			widget = wibox.widget.textbox,
			text = "Connection name"
		}
	}
})
local conn_expand = wibox.widget({
	widget = wibox.container.background,
	bg = beautiful.colors.iris, fg = beautiful.colors.hl_low,
	shape = partial.right,
	{
		widget = wibox.container.margin,
		margins = dpi(2),
		{
			widget = wibox.widget.textbox,
			font = beautiful.fonts.nerd..12,
			text = ""
		}
	}
})
local conn_recieve = wibox.widget.textbox("0 B/s")
local conn_transfer = wibox.widget.textbox("0 B/s")

local function update_available_connections(connections)
	for _, info in ipairs(wifi.known_connections) do
		info.available = false
		for _, conn_path in ipairs(connections) do
			if info.connection == conn_path then
				info.available = true
				break
			end
		end
	end
end
update_available_connections(wl_device.AvailableConnections)

local conn_list = wibox.layout.fixed.vertical()
for _, info in pairs(wifi.known_connections) do
	local item = wibox.widget({
		widget = wibox.container.background,
		{
			widget = wibox.container.margin,
			top = dpi(2), bottom = dpi(2),
			{
				widget = wibox.widget.textbox,
				text = info.id
			},
		}
	})
	if not info.available then
		item.fg = beautiful.colors.muted
	end
	item:buttons(
	awful.button({ }, 1, function()
		if not info.available then return end
		naughty.notify({
			title = "Wireless connection",
			text = ("Attempt to connect to '%s'"):format(info.id)
		})
		wifi.server:ActivateConnection(info.connection, wl_device.object_path, "/")
	end)
	)
	conn_list:add(item)
end

local known_conn = awful.popup({
	widget = {
		widget = wibox.container.background,
		{
			widget = wibox.container.margin,
			margins = dpi(5),
			conn_list
		},
	},
	shape = function(cr, w, h) gshape.rounded_rect(cr, w, h, 5) end,
	border_width = dpi(2),
	border_color = beautiful.colors.iris,
	placement = { },
	ontop = true,
	visible = false,
})

conn_expand:buttons(
	awful.button({ }, 1, function()
		known_conn.visible = not known_conn.visible
		if not known_conn.visible then return end
		awful.placement.next_to(known_conn, {
			preferred_positions = { "right" },
			preferred_anchors = { "front" },
		})
	end)
)

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
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = dpi(2),
					conn_label,
					conn_expand,
				},
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
		known_conn.visible = false
		return
	end
	if not wifi_popup.visible then
		known_conn.visible = false
		return
	end
	awful.placement.next_to(wifi_popup, {
		preferred_positions = { "bottom" },
		preferred_anchors = { "middle" },
		mode = "cursor_inside",
		offset = { y = 5 },
	})
end)

wl_device.on.StateChanged(state_updated)
wl_device.on.PropertiesChanged(function(changed)
	if changed.AvailableConnections then
		update_available_connections(changed.AvailableConnections)
		for i, info in ipairs(wifi.known_connections) do
			if info.available then
				conn_list.children[i].fg = nil
			else
				conn_list.children[i].fg = beautiful.colors.muted
			end
		end
	end
end)

wl_wireless.on.PropertiesChanged(function(changed)
	if changed.ActiveAccessPoint ~= nil then
		prepare_ap(changed.ActiveAccessPoint)
	end
end)

wl_props:SetAsync(
	function() end, nil,
	IFACE.statistics, "RefreshRateMs", GLib.Variant.new("u", 5000)
)
wl_stats.on.PropertiesChanged(function(changed)
	if changed.RxBytes then
		conn_recieve.text = exchange_rate(changed.RxBytes, "recv")
	end
	if changed.TxBytes then
		conn_transfer.text = exchange_rate(changed.TxBytes, "tran")
	end
end)

state_updated(wl_device.State)
prepare_ap(wl_wireless.ActiveAccessPoint)

return bar_widget
