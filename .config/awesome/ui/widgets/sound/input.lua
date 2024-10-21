local Capi = {
	awesome = awesome
}
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local wibox = require("wibox")
local naughty = require("naughty")

local GLib = require("lgi").GLib
local dbus = require("modules.dbus-lua")
local pulse = require("sys").pulse
local snd_enums = pulse.enums

local core_obj = pulse.object
local IFACE = {
	properties = "org.freedesktop.DBus.Properties",
	device = pulse.base..".Device",
	device_port = pulse.base..".DevicePort",
}

local core_core = core_obj:implement(pulse.base)

-- This function, in this file, is wrong. Precisely because it is wrong that we
-- get the correct answer at the end. The PulseAudio source Device does not show
-- the correct BaseVolume value. I do not know why. I am too tired to find out
-- now. If I find the reason and it is within me to update this function, I
-- will. If the problem is resolved from PulseAudio's side then I will be more
-- than happy.
local function volume_percent(volume, base_volume)
	return math.ceil(10 * volume / base_volume)
end

local source_path = core_core:GetSourceByName("@DEFAULT_SOURCE@")
local source_obj = dbus.ObjectProxy.new(core_obj.connection, source_path, nil)
local source_props = source_obj:implement(IFACE.properties)
local source_device = source_obj:implement(IFACE.device)

local source_label = wibox.widget.textbox()
source_label.text = volume_percent(
	source_device.Volume[1], source_device.BaseVolume
)
local source_icon = wibox.widget.textbox(source_device.State == 0 and "󰍬" or "󰍮")
source_icon.font = beautiful.fonts.nerd..12

local source_widget = wibox.widget({
	layout = wibox.layout.fixed.horizontal,
	{
		widget = wibox.container.background,
		shape = beautiful.shapes.partial_rounded_left,
		fg = beautiful.widget_active_fg, bg = beautiful.widget_active_bg,
		{
			widget = wibox.container.margin,
			left = dpi(4), right = dpi(3), top = dpi(2), bottom = dpi(2),
			source_icon,
		}
	},
	{
		widget = wibox.container.background,
		shape = beautiful.shapes.partial_rounded_right,
		shape_border_width = dpi(1),
		shape_border_color = beautiful.widget_active_bg,
		{
			widget = wibox.container.margin,
			left = dpi(7), right = dpi(5),
			source_label,
		}
	}
})
if source_device.Mute then
	source_widget.children[2].fg = beautiful.label_disabled_fg
else
	source_widget.children[2].fg = beautiful.label_enabled_fg
end

local slider = wibox.widget({
	widget = wibox.widget.slider,
	bar_height = dpi(2),
	bar_shape = beautiful.shapes.bar,
	handle_shape = beautiful.shapes.rounded_small,
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
		shape = beautiful.shapes.rounded_small,
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
		item.bg = beautiful.list_active_bg
		item.fg = beautiful.list_active_fg
	end
	item:buttons(
		awful.button({ }, 1, function()
			if p.Available == snd_enums.NO then
				return
			end
			if source_props:Get(IFACE.device, "ActivePort") ~= path then
				source_props:Set(IFACE.device, "ActivePort", GLib.Variant.new("o", path))
			end
		end)
	)
	p.on.AvailableChanged(function(available)
		if available == 1 then
			item.fg = beautiful.list_disabled_fg
		else
			item.fg = beautiful.list_normal_fg
		end
	end)
	ports_layout:add(item)
end

local source_popup = awful.popup({
	widget = {
		widget = wibox.container.background,
		bg = beautiful.popup_bg,
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
	shape = beautiful.shapes.rounded_large,
	border_width = beautiful.popup_border_width,
	border_color = beautiful.popup_border_color,
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
	source_label.text = volume_percent(volume[1], source_device.BaseVolume)
	slider.value = volume_percent(volume[1], source_device.BaseVolume)
end)
source_device.on.MuteUpdated(function(mute)
	if mute then
		source_widget.children[2].fg = beautiful.list_disabled_fg
	else
		source_widget.children[2].fg = beautiful.list_normal_fg
	end
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
	ports_layout.children[_active_port_idx].bg = beautiful.list_active_bg
	ports_layout.children[_active_port_idx].fg = beautiful.list_active_fg
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
