local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gshape = require("gears.shape")
local wibox = require("wibox")

local sound = require("sys.sound")

local sink_path = sound.GetSinkByName("@DEFAULT_SINK@")
local sink = sound.Device(sink_path)

sound.ListenForSignal("org.PulseAudio.Core1.Device.VolumeUpdated", {
	sink_path,
})
sound.ListenForSignal("org.PulseAudio.Core1.Device.MuteUpdated", {
	sink_path,
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

local bar_wgt_label = wibox.widget.textbox()
bar_wgt_label.text = volume_text(sink.Mute, sink.Volume[1], sink.BaseVolume)
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

-- volume_popup.uid = 220

sink.connect_signal(function(self, _)
	bar_wgt_label.text = volume_text(self.Mute, self.Volume[1], self.BaseVolume)
end, "VolumeUpdated")
sink.connect_signal(function(self, _)
	bar_wgt_label.text = volume_text(self.Mute, self.Volume[1], self.BaseVolume)
end, "MuteUpdated")

return bar_wgt
