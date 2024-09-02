local wibox = require("wibox")
local gshape = require("gears.shape")

local wireless = require("sys.network.wireless")
local net_enums = require("sys.network.enums")

local wgt_label = wibox.widget.textbox("WiFi")
local bar_widget = wibox.widget({
	widget = wibox.container.background,
	bg = "#26288f",
	shape = function(cr, w, h) gshape.rounded_rect(cr, w, h, 2) end,
	{
		widget = wibox.container.margin,
		top = 2, bottom = 2, left = 5, right = 5,
		wgt_label
	}
})

wireless.socket:connect_signal("StateChanged", function(_, state)
	if state.new == net_enums.DeviceState.ACTIVATED then
		wgt_label.text = string.char(table.unpack(wireless.active_ap.Ssid))
	else
		wgt_label.text = "new: "..state.new..", old: "..state.old..", reason: "..state.reason
	end
end)

return bar_widget
