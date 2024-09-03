local awful = require("awful")
local wibox = require("wibox")
local gshape = require("gears.shape")

local wireless = require("sys.network.wireless")
local net_enums = require("sys.network.enums")

local icons = {
	"󰤟",
	"󰤢",
	"󰤥",
	"󰤨",
}

local wgt_icon = wibox.widget.textbox("00")
local bar_widget = wibox.widget({
	widget = wibox.container.background,
	bg = "#26288f",
	shape = function(cr, w, h) gshape.rounded_rect(cr, w, h, 2) end,
	{
		widget = wibox.container.margin,
		top = 2, bottom = 2, left = 5, right = 5,
		wgt_icon
	}
})

local tooltip = awful.tooltip({ })
tooltip:add_to_object(bar_widget)

wireless.socket:connect_signal("StateChanged", function(_, state)
	if state.new == net_enums.DeviceState.UNKNOWN then
		tooltip.text = "??"
	elseif state.new == net_enums.DeviceState.UNAVAILABLE then
		tooltip.text = "WiFi off"
	elseif state.new == net_enums.DeviceState.DISCONNECTED then
		tooltip.text = "Disconnected"
	elseif state.new >= net_enums.DeviceState.PREPARE and
		     state.new <= net_enums.DeviceState.SECONDARIES then
		tooltip.text = "Connecting..."
	elseif state.new == net_enums.DeviceState.ACTIVATED then
		local ap_inuse = wireless.AccessPoint(wireless.Device.ActiveAccessPoint)
		tooltip.text = string.char(table.unpack(ap_inuse.Ssid))
	else
		tooltip.text = "new: "..state.new..", old: "..state.old..", reason: "..state.reason
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
				wgt_icon.text = icons[level]
			end
		end
	end
)
wireless.socket:emit_signal("StateChanged", {
	new = wireless.Device.State, old = 0, reason = 0
})

return bar_widget
