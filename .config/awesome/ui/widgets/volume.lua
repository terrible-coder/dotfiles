local Capi = {
	awesome = awesome,
}
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gshape = require("gears.shape")
local wibox = require("wibox")
local pulse_dbus = require("pulseaudio_dbus-master")

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

local bar_wgt_label = wibox.widget.textbox(tostring(sinks[1]:get_volume_percent()[1]))
local bar_wgt_icon = wibox.widget.textbox("")
bar_wgt_icon.font = beautiful.fonts.nerd..16

local bar_wgt = wibox.widget({
	layout = wibox.layout.fixed.horizontal,
	-- spacing = 5,
	{
		widget = wibox.container.background,
		shape = function(cr, w, h)
			gshape.partially_rounded_rect(cr, w, h, true, false, false, true, dpi(2))
		end,
		fg = beautiful.colors.hl_low, bg = beautiful.colors.foam,
		{
			widget = wibox.container.margin,
			left = dpi(5), right = dpi(5), top = dpi(2), bottom = dpi(2),
			bar_wgt_icon,
		}
	},
	{
		widget = wibox.container.background,
		bg = beautiful.colors.hl_low,
		shape = function(cr, w, h)
			gshape.partially_rounded_rect(cr, w, h, false, true, true, false, dpi(2))
		end,
		{
			widget = wibox.container.margin,
			left = dpi(10), right = dpi(5),
			bar_wgt_label,
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

local pulse_layout = wibox.layout.fixed.vertical()
for i, sink in ipairs(sinks) do
	local sink_menu = wibox.layout.fixed.horizontal()
	sink_menu.spacing = 5
	sink_menu:add(wibox.widget.textbox("Sink"..(i-1)))
	local port_menu = wibox.layout.fixed.vertical()
	for _, p_path in ipairs(sink.Ports) do
		local port = pulse_dbus.get_port(connection, p_path)
		local port_label = wibox.widget.textbox(port.Description)
		port_label.path = p_path
		port_menu:add(port_label)
	end
	sink_menu:add(port_menu)
	pulse_layout:add(sink_menu)
end

function pulse_layout:update_active()
	for i, s_menu in ipairs(self.children) do
		local p_menu = s_menu.children[2].children
		for _, p_label in ipairs(p_menu) do
			if p_label.path == sinks[i]:get_active_port() then
				p_label.text = p_label.text.."*"
			else
				p_label.text = p_label.text:match("(.-)%*?$")
			end
		end
	end
end
pulse_layout:update_active()

local function listen_device(device)
	if device.signals.VolumeUpdated then
		device:connect_signal(function(this, _)
			bar_wgt_label.text = this:get_volume_percent()[1]
			pulse_layout:update_active()
		end, "VolumeUpdated")
	end
	if device.signals.MuteUpdated then
		device:connect_signal(function(this, is_mute)
			if is_mute then
				bar_wgt_label.text = "Muted"
			else
				bar_wgt_label.text = this:get_volume_percent()[1]
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

local volume_popup = awful.popup({
	widget = {
		widget = wibox.container.background,
		bg = beautiful.colors.overlay,
		{
			widget = wibox.container.margin,
			top = 10, bottom = 10, left = 15, right = 15,
			pulse_layout
		}
	},
	shape = function(cr, w, h) gshape.rounded_rect(cr, w, h, 5) end,
	border_width = dpi(2),
	border_color = beautiful.colors.iris,
	placement = { },
	ontop = true,
	visible = false,
})

volume_popup.uid = 220

bar_wgt:buttons(
	awful.button({ }, 1,
	function() Capi.awesome.emit_signal("popup_show", volume_popup.uid) end)
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

return bar_wgt
