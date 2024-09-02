local wibox = require("wibox")
local gshape = require("gears.shape")

local wireless = require("sys.network.wireless")
local net_enums = require("sys.network.enums")

local wgt_label = wibox.widget.textbox("WiFi")
local wgt_icon = wibox.widget.textbox("00")
local bar_widget = wibox.widget({
	widget = wibox.container.background,
	bg = "#26288f",
	shape = function(cr, w, h) gshape.rounded_rect(cr, w, h, 2) end,
	{
		widget = wibox.container.margin,
		top = 2, bottom = 2, left = 5, right = 5,
		{
			layout = wibox.layout.fixed.horizontal,
			spacing = 2,
			wgt_icon, wgt_label
		}
	}
})

wireless.socket:connect_signal("StateChanged", function(_, state)
	if state.new == net_enums.DeviceState.UNKNOWN then
		wgt_label.text = "??"
	elseif state.new == net_enums.DeviceState.UNAVAILABLE then
		wgt_label.text = "WiFi off"
	elseif state.new == net_enums.DeviceState.DISCONNECTED then
		wgt_label.text = "Disconnected"
	elseif state.new >= net_enums.DeviceState.PREPARE and
		     state.new <= net_enums.DeviceState.SECONDARIES then
		wgt_label.text = "Connecting..."
	elseif state.new == net_enums.DeviceState.ACTIVATED then
		local ap_inuse = wireless.AccessPoint(wireless.Device.ActiveAccessPoint)
		wgt_label.text = string.char(table.unpack(ap_inuse.Ssid))
	else
		wgt_label.text = "new: "..state.new..", old: "..state.old..", reason: "..state.reason
	end
end)

wireless.socket:connect_signal(
	"AccessPoint::PropertiesChanged",
	function(_, path, changed)
		if path ~= wireless.Device.ActiveAccessPoint then
			return
		end
		if changed.Strength then
			wgt_icon.text = tostring(changed.Strength)
		end
	end
)
wireless.socket:emit_signal("StateChanged", {
	new = wireless.Device.State, old = 0, reason = 0
})

return bar_widget
