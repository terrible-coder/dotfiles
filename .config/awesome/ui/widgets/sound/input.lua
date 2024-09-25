local Capi = {
	awesome = awesome
}
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gshape = require("gears.shape")
local wibox = require("wibox")
local naughty = require("naughty")

local GLib = require("lgi").GLib
local dbus = require("modules.dbus-lua")
local pulse = require("sys").pulse

local core_obj = pulse.object
local IFACE = {
	properties = "org.freedesktop.DBus.Properties",
	device = pulse.base..".Device",
	device_port = pulse.base..".DevicePort",
}

local core_core = core_obj:implement(pulse.base)
-- local sound = require("sys.sound")

-- This function, in this file, is wrong. Precisely because it is wrong that we
-- get the correct answer at the end. The PulseAudio source Device does not show
-- the correct BaseVolume value. I do not know why. I am too tired to find out
-- now. If I find the reason and it is within me to update this function, I
-- will. If the problem is resolved from PulseAudio's side then I will be more
-- than happy.
local function volume_percent(volume, base_volume)
	return math.ceil(10 * volume / base_volume)
end

local function volume_text(mute, volume, base_volume)
	if mute then
		return "Muted"
	else
		return volume_percent(volume, base_volume)
	end
end

local source_path = core_core:GetSourceByName("@DEFAULT_SOURCE@")
local source_obj = dbus.ObjectProxy.new(core_obj.connection, source_path, nil)
local source_props = source_obj:implement(IFACE.properties)
local source_device = source_obj:implement(IFACE.device)

local source_label = wibox.widget.textbox()
source_label.text = volume_text(
	source_device.Mute, source_device.Volume[1], source_device.BaseVolume
)
local source_icon = wibox.widget.textbox(source_device.State == 0 and "󰍬" or "󰍮")
source_icon.font = beautiful.fonts.nerd..12

local source_widget = wibox.widget({
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
			source_icon,
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
			source_label,
		}
	}
})

local slider = wibox.widget({
	widget = wibox.widget.slider,
	bar_height = dpi(2),
	bar_shape = gshape.rounded_bar,
	bar_color = beautiful.colors.pine,
	handle_shape = function(cr, w, h) gshape.rounded_rect(cr, w, h, 2) end,
	handle_width = dpi(10),
	handle_margins = { top = 2, bottom = 2 },
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
	-- This calculation is wrong for the same reason the volume_percent function
	-- is wrong. Check function comment.
	local new_volume = math.floor(source_device.BaseVolume * slider.value / 10)
	source_props:Set(
		IFACE.device, "Volume",
		GLib.Variant.new("au", { new_volume, new_volume })
	)
end)

slider.value = volume_percent(source_device.Volume[1], source_device.BaseVolume)

local _active_port = source_device.ActivePort
local _active_port_idx = 0

local ports_layout = wibox.layout.flex.vertical()
for i, path in ipairs(source_device.Ports) do
	local p = dbus.Proxy.new(
		dbus.ObjectProxy.new(core_obj.connection, path, nil),
		IFACE.device_port
	)
	local item = wibox.widget({
		widget = wibox.container.background,
		shape = function(cr, w, h) gshape.rounded_rect(cr, w, h, 2) end,
		{
			widget = wibox.container.margin,
			left = dpi(5), right = dpi(5), top = dpi(2), bottom = dpi(2),
			{
				widget = wibox.widget.textbox,
				text = p.Description,
			}
		}
	})
	if path == _active_port then
		_active_port_idx = i
		item.bg = beautiful.colors.iris
		item.fg = beautiful.colors.hl_low
	end
	item:buttons(
		awful.button({ }, 1, function()
			if p.Available == 1 then
				return
			end
			if source_props:Get(IFACE.device, "ActivePort") ~= path then
				source_props:Set(IFACE.device, "ActivePort", GLib.Variant.new("o", path))
			end
		end)
	)
	p.on.AvailableChanged(function(available)
		if available == 1 then
			item.fg = beautiful.colors.muted
		else
			item.fg = nil
		end
	end)
	ports_layout:add(item)
end

local source_popup = awful.popup({
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
					spacing = dpi(20),
					{
						widget = wibox.widget.textbox,
						markup = "<b>Audio input</b>",
					},
					nil,
					text_label,
				},
				{
					widget = wibox.container.margin,
					top = dpi(5), bottom = dpi(5),
					slider,
				},
				{
					widget = wibox.widget.textbox,
					text = source_device.PropertyList["device.description"]
				},
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = dpi(10),
					{
						widget = wibox.widget.textbox,
						valign = "top",
						text = "Ports:",
					},
					ports_layout,
				},
			},
		}
	},
	shape = function(cr, w, h) gshape.rounded_rect(cr, w, h, 5) end,
	border_width = dpi(2),
	border_color = beautiful.colors.iris,
	placement = { },
	ontop = true,
	visible = false,
})

source_popup.uid = 222

source_widget:buttons(
	awful.button({ }, 1,
	function()
		Capi.awesome.emit_signal("popup_show", source_popup.uid)
	end)
)

Capi.awesome.connect_signal("popup_show", function(uid)
	if uid == source_popup.uid then
		source_popup.visible = not source_popup.visible
	else
		source_popup.visible = false
	end
	if not source_popup.visible then return end
	awful.placement.next_to(source_popup, {
		preferred_positions = { "bottom" },
		preferred_anchors = { "middle" },
		mode = "cursor_inside",
		offset = { y = 5 },
	})
end)

source_device.on.VolumeUpdated(function(volume)
	local mute = source_props:Get(IFACE.device, "Mute")
	source_label.text = volume_text(mute, volume[1], source_device.BaseVolume)
	slider.value = volume_percent(volume[1], source_device.BaseVolume)
end)
source_device.on.MuteUpdated(function(mute)
	local volume = source_props:Get(IFACE.device, "Volume")
	source_label.text = volume_text(mute, volume[1], source_device.BaseVolume)
end)
source_device.on.ActivePortUpdated(function(active_port_path)
	if active_port_path == _active_port then return end
	ports_layout.children[_active_port_idx].bg = nil
	ports_layout.children[_active_port_idx].fg = nil
	_active_port = active_port_path
	for i, path in ipairs(source_device.Ports) do
		if path == active_port_path then
			_active_port_idx = i
			break
		end
	end
	ports_layout.children[_active_port_idx].bg = beautiful.colors.iris
	ports_layout.children[_active_port_idx].fg = beautiful.colors.hl_low
end)
source_device.on.StateUpdated(function(state)
	if state == 0 then
		source_icon.text = "󰍬"
		naughty.notify({
			title = "Microphone",
			text = "Listening"
		})
	else
		source_icon.text = "󰍮"
		naughty.notify({
			title = "Microphone",
			text = "Suspended"
		})
	end
end)

return {
	widget = source_widget,
	object = source_obj
}
