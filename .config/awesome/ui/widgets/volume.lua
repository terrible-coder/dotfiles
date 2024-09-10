local Capi = {
	awesome = awesome
}
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gshape = require("gears.shape")
local wibox = require("wibox")
local naughty = require("naughty")

local sound = require("sys.sound")

local sink_path = sound.GetSinkByName("@DEFAULT_SINK@")
local sink = sound.Device(sink_path)

local source_path = sound.GetSourceByName("@DEFAULT_SOURCE@")
local source = sound.Device(source_path)

sound.ListenForSignal("org.PulseAudio.Core1.Device.VolumeUpdated", {
	sink_path, source_path,
})
sound.ListenForSignal("org.PulseAudio.Core1.Device.MuteUpdated", {
	sink_path, source_path,
})
sound.ListenForSignal("org.PulseAudio.Core1.Device.ActivePortUpdated", {
	sink_path,
})
sound.ListenForSignal("org.PulseAudio.Core1.Device.StateUpdated", {
	source_path,
})

local function volume_percent(volume, base_volume)
	return math.ceil(100 * volume / base_volume)
end

local function volume_text(mute, volume, base_volume)
	if mute then
		return "Muted"
	else
		return volume_percent(volume, base_volume)
	end
end

local sink_label = wibox.widget.textbox()
sink_label.text = volume_text(sink.Mute, sink.Volume[1], sink.BaseVolume)
local sink_icon = wibox.widget.textbox("")
sink_icon.font = beautiful.fonts.nerd..16

local sink_widget = wibox.widget({
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
			sink_icon,
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
			sink_label,
		}
	}
})

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

-- local slider = wibox.widget({
-- 	widget = wibox.widget.slider,
-- 	bar_height = 2, bar_width = 30,
-- 	bar_shape = gshape.rounded_bar,
-- 	handle_shape = function(cr, w, h) gshape.circle(cr, w, h, 5) end,
-- 	handle_width = 5,
-- 	handle_margins = { top = 2, bottom = 2 },
-- 	minimum = 0, maximum = 100,
-- 	forced_width = 120, forced_height = 5,
-- 	value = 0,
-- })
-- 
-- local text_label = wibox.widget.textbox("00")
-- 
-- -- prevent flooding system with mutliple calls to external programmes
-- local slider_drag = true
-- slider:connect_signal("property::value", function(self)
-- 	slider_drag = true
-- 	text_label.text = ("%02d%%"):format(self.value)
-- end)
-- 
-- -- this trigger is fired relying solely on
-- -- https://github.com/awesomeWM/awesome/issues/1241#issuecomment-264109466
-- -- does not work in v4.3
-- slider:connect_signal("button::release", function()
-- 		if not slider_drag then return end
-- 		slider_drag = false
-- 		server:change(slider.value - server.volume)
-- end)

-- Record for when ActivePortUpdated. This is assuming that the order won't
-- change.
local port_paths = { }

local ports_layout = wibox.layout.flex.vertical()
local active_port_path = sink.ActivePort
for i, path in ipairs(sink.Ports) do
	port_paths[i] = path
	local item = wibox.widget({
		widget = wibox.container.background,
		bg = path == active_port_path and beautiful.colors.iris or nil,
		fg = path == active_port_path and beautiful.colors.hl_low or nil,
		shape = function(cr, w, h) gshape.rounded_rect(cr, w, h, 2) end,
		{
			widget = wibox.container.margin,
			left = dpi(5), right = dpi(5), top = dpi(2), bottom = dpi(2),
			{
				widget = wibox.widget.textbox,
				text = sound.DevicePort(path).Description,
			}
		}
	})
	ports_layout:add(item)
end

local volume_popup = awful.popup({
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

volume_popup.uid = 220

sink_widget:buttons(
	awful.button({ }, 1,
	function()
		Capi.awesome.emit_signal("popup_show", volume_popup.uid)
	end)
)

Capi.awesome.connect_signal("popup_show", function(uid)
	if uid == volume_popup.uid then
		volume_popup.visible = not volume_popup.visible
	else
		volume_popup.visible = false
	end
	if not volume_popup.visible then return end
	awful.placement.next_to(volume_popup, {
		preferred_positions = { "bottom" },
		preferred_anchors = { "middle" },
		mode = "cursor_inside",
		offset = { y = 5 },
	})
end)

sink.connect_signal(function(_, _)
	sink_label.text = volume_text(sink.Mute, sink.Volume[1], sink.BaseVolume)
end, "VolumeUpdated")
sink.connect_signal(function(_, _)
	sink_label.text = volume_text(sink.Mute, sink.Volume[1], sink.BaseVolume)
end, "MuteUpdated")
sink.connect_signal(function(_, new_active)
	active_port_path = new_active
	for i, path in ipairs(port_paths) do
		local bg = path == active_port_path and beautiful.colors.iris or nil
		local fg = path == active_port_path and beautiful.colors.hl_low or nil
		ports_layout.children[i].bg = bg
		ports_layout.children[i].fg = fg
	end
end, "ActivePortUpdated")

source.connect_signal(function(_, _)
	source_label.text = volume_text(source.Mute, source.Volume[1], source.BaseVolume)
end, "VolumeUpdated")
source.connect_signal(function(_, _)
	source_label.text = volume_text(source.Mute, source.Volume[1], source.BaseVolume)
end, "MuteUpdated")

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
	sink = sink_widget,
	source = source_widget,
}
