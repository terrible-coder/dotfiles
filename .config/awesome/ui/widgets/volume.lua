-- local Capi = {
-- 	awesome = awesome,
-- }
-- local awful = require("awful")
local gshape = require("gears.shape")
local wibox = require("wibox")
local pulse_dbus = require("pulseaudio_dbus")

local address = pulse_dbus.get_address()
local connection = pulse_dbus.get_connection(address)
local core = pulse_dbus.get_core(connection)
local sinks = { }
for i, v in ipairs(core:get_sinks()) do
	sinks[i] = pulse_dbus.get_device(connection, v)
end
local sources = { }
for i, v in ipairs(core:get_sources()) do
	sources[i] = pulse_dbus.get_device(connection, v)
end

-- this will listen for these signals from every object
core:ListenForSignal("org.PulseAudio.Core1.Device.VolumeUpdated", { })
core:ListenForSignal("org.PulseAudio.Core1.Device.MuteUpdated", { })

local bar_wgt_label = wibox.widget.textbox(sinks[1]:get_volume_percent()[1].."%")

local bar_wgt = wibox.widget({
	widget = wibox.container.background,
	bg = "#26288f",
	shape = function(cr, w, h) gshape.rounded_rect(cr, w, h, 2) end,
	{
		widget = wibox.container.margin,
		left = 5, right = 5, top = 2, bottom = 2,
		{
			layout = wibox.layout.fixed.horizontal,
			spacing = 5,
			{
				widget = wibox.widget.textbox,
				id = "icon",
				text = "",
			},
			bar_wgt_label,
		}
	}
})

local function listen_device(device)
	if device.signals.VolumeUpdated then
		device:connect_signal(function(this, _)
			bar_wgt_label.text = this:get_volume_percent()[1].."%"
		end, "VolumeUpdated")
	end
	if device.signals.MuteUpdated then
		device:connect_signal(function(this, is_mute)
			if is_mute then
				bar_wgt_label.text = "Muted"
			else
				bar_wgt_label.text = this:get_volume_percent()[1].."%"
			end
		end, "MuteUpdated")
	end
end

for _, v in ipairs(sinks) do
	listen_device(v)
end
for _, v in ipairs(sources) do
	if v.Name and not v.Name:match("%.monitor$") then
		listen_device(v)
	end
end

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
-- 
-- local volume_popup = awful.popup({
-- 	widget = {
-- 		widget = wibox.container.background,
-- 		bg = "#268f28",
-- 		{
-- 			widget = wibox.container.margin,
-- 			top = 10, bottom = 10, left = 15, right = 15,
-- 			{
-- 				layout = wibox.layout.fixed.vertical,
-- 				spacing = 5,
-- 				{
-- 					widget = wibox.widget.textbox,
-- 					text = "Volume",
-- 				},
-- 				{
-- 					layout = wibox.layout.fixed.horizontal,
-- 					spacing = 10,
-- 					slider,
-- 					text_label
-- 				}
-- 			}
-- 		}
-- 	},
-- 	shape = function(cr, w, h) gshape.rounded_rect(cr, w, h, 5) end,
-- 	placement = { },
-- 	ontop = true,
-- 	visible = false,
-- })

-- volume_popup.uid = 220
-- 
-- bar_wgt:buttons(
-- 	awful.button({ }, 1,
-- 	function()
-- 		Capi.awesome.emit_signal("popup_show", volume_popup.uid)
-- 	end)
-- )
-- 
-- Capi.awesome.connect_signal("popup_show", function(uid)
-- 	if uid == volume_popup.uid then
-- 		volume_popup.visible = not volume_popup.visible
-- 	else
-- 		volume_popup.visible = false
-- 	end
-- 	if not volume_popup.visible then return end
-- 	awful.placement.next_to(volume_popup, {
-- 		preferred_positions = { "bottom" },
-- 		preferred_anchors = { "middle" },
-- 		mode = "cursor_inside",
-- 		offset = { y = 5 },
-- 	})
-- end)

return bar_wgt
