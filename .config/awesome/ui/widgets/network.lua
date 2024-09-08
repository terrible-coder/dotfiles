local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local wibox = require("wibox")
local gshape = require("gears.shape")

local wireless = require("sys.network.wireless")
local net_enums = require("sys.network.enums")

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

local wgt_icon = wibox.widget.textbox(icons.unavailable)
wgt_icon.font = beautiful.fonts.nerd..16
local wgt_label = wibox.widget.textbox("WiFi off")

local bar_widget = wibox.widget({
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
			wgt_icon,
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
			left = dpi(10), right = dpi(5),
			wgt_label,
		}
	}
})

wireless.socket:connect_signal("StateChanged", function(_, state)
	if state.new == net_enums.DeviceState.UNKNOWN then
		wgt_icon.text = icons.unknown
		wgt_label.text = "??"
	elseif state.new == net_enums.DeviceState.UNAVAILABLE then
		wgt_icon.text = icons.unavailable
		wgt_label.text = "WiFi off"
	elseif state.new == net_enums.DeviceState.DISCONNECTED then
		wgt_icon.text = icons.disconnected
		wgt_label.text = "Disconnected"
	elseif state.new >= net_enums.DeviceState.PREPARE and
		     state.new <= net_enums.DeviceState.SECONDARIES then
		wgt_icon.text = icons.connecting
		wgt_label.text = "Connecting..."
	elseif state.new == net_enums.DeviceState.ACTIVATED then
		local ap_inuse = wireless.AccessPoint(wireless.Device.ActiveAccessPoint)
		wgt_icon.text = icons.activated[1]
		wgt_label.text = string.char(table.unpack(ap_inuse.Ssid))
	else
		wgt_label.text = "new: "..state.new..", old: "..state.old..", reason: "..state.reason
	end
end)

local _last_level = 0

wireless.socket:connect_signal(
	"AccessPoint::PropertiesChanged",
	function(_, path, changed)
		if path ~= wireless.Device.ActiveAccessPoint then
			return
		end
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
	end
)
wireless.socket:emit_signal("StateChanged", {
	new = wireless.Device.State, old = 0, reason = 0
})

return bar_widget
