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

-- Record for when ActivePortUpdated. This is assuming that the order won't
-- change.
local port_paths = { }

local ports_layout = wibox.layout.flex.vertical()
local active_port_path = source.ActivePort
for i, path in ipairs(source.Ports) do
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
source.connect_signal(function(_, new_active)
	active_port_path = new_active
	for i, path in ipairs(port_paths) do
		if path == active_port_path then
			ports_layout.children[i].bg = beautiful.colors.iris
			ports_layout.children[i].fg = beautiful.colors.hl_low
			naughty.notify({
				title = "Audio input",
				text = ("Port change to '%s'"):format(
					ports_layout.children[i].children[1].children[1].text
				)
			})
		else
			ports_layout.children[i].bg = nil
			ports_layout.children[i].fg = nil
		end
	end
end, "ActivePortUpdated")
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
