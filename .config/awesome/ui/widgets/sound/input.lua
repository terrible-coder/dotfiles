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
	widget = source_widget,
	object = source
}
