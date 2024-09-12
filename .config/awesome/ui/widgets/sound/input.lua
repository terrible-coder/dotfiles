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
local sound = require("sys.sound")

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

local source_path = sound.GetSourceByName("@DEFAULT_SOURCE@")
local source = sound.Device(source_path)

local source_label = wibox.widget.textbox()
source_label.text = volume_text(source.Mute, source.Volume[1], source.BaseVolume)
local source_icon = wibox.widget.textbox(source.State == 0 and "󰍬" or "󰍮")
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

-- Record for when ActivePortUpdated. This is assuming that the order won't
-- change.
local ports = { }
for i, path in ipairs(source.Ports) do
	ports[i] = sound.DevicePort(path)
end

local ports_layout = wibox.layout.flex.vertical()
for _, p in ipairs(ports) do
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
	item:buttons(
		awful.button({ }, 1, function()
			if p.Available == 1 then
				return
			end
			if source.ActivePort ~= p.object_path then
				source.ActivePort = GLib.Variant.new("o", p.object_path)
			end
		end)
	)
	ports_layout:add(item)
end

local function update_port(index, port)
	local bg, fg = nil, nil
	if port.Available == 1 then
		bg = nil
		fg = beautiful.colors.muted
	else
		if port.object_path == source.ActivePort then
			bg = beautiful.colors.iris
			fg = beautiful.colors.hl_low
		end
	end
	ports_layout.children[index].bg = bg
	ports_layout.children[index].fg = fg
end

local function update_all_ports()
	for i, p in ipairs(ports) do
		update_port(i, p)
	end
end
update_all_ports()

local source_popup = awful.popup({
	widget = {
		widget = wibox.container.margin,
		margins = dpi(5),
		ports_layout,
	},
	shape = function(cr, w, h) gshape.rounded_rect(cr, w, h, 5) end,
	border_width = dpi(2),
	border_color = beautiful.colors.iris,
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

source.connect_signal(function(_, _)
	source_label.text = volume_text(source.Mute, source.Volume[1], source.BaseVolume)
end, "VolumeUpdated")
source.connect_signal(function(_, _)
	source_label.text = volume_text(source.Mute, source.Volume[1], source.BaseVolume)
end, "MuteUpdated")
source.connect_signal(function()
	update_all_ports()
end, "ActivePortUpdated")
for i, p in ipairs(ports) do
	p.connect_signal(function()
		update_port(i, p)
	end, "AvailableChanged")
end
source.connect_signal(function(_, state)
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
end, "StateUpdated")

return {
	widget = source_widget,
	object = source
}
