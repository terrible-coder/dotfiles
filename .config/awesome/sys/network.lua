local naughty = require("naughty")
local proxy = require("dbus_proxy")

local NM_NAME  = "org.freedesktop.NetworkManager"
local NM_PATH  = "/org/freedesktop/NetworkManager"
local NM_IFACE = "org.freedesktop.NetworkManager"

local nm_server = proxy.Proxy:new({
	bus = proxy.Bus.SYSTEM,
	name = NM_NAME,
	path = NM_PATH,
	interface = NM_IFACE
})

-- It is "wlp3s0" for me. I am aware it maybe different for other systems but I
-- do not know how to check for that yet.
local wireless_path = nm_server:GetDeviceByIpIface("wlp3s0")
if not wireless_path then
	naughty.notify({
		title = "Networking",
		text = "Could not find wireless device \"wlp3s0\". Is it connected?",
		preset = naughty.config.presets.critical
	})
end
naughty.notify({ title = "Networking", text = "Wireless dev: "..wireless_path, timeout = 0 })
local wireless = proxy.Proxy:new({
	bus = proxy.Bus.SYSTEM,
	name = NM_NAME,
	path = wireless_path,
	interface = NM_IFACE..".Device"
})

local function get_ActiveAccessPoint()
	local active_ap_path = wireless:Get(NM_IFACE..".Device.Wireless", "ActiveAccessPoint")
	naughty.notify({ title = "Networking", text = "Active AP: "..active_ap_path, timeout = 0 })
	local active_ap = proxy.Proxy:new({
		bus = proxy.Bus.SYSTEM,
		name = NM_NAME,
		path = active_ap_path,
		interface = NM_IFACE..".AccessPoint"
	})

	naughty.notify({
		title = "Networking",
		text = "Current AP: "..string.char(table.unpack(active_ap.Ssid))
	})
end

if wireless:Get(NM_IFACE..".Device", "State") == 100 then
	get_ActiveAccessPoint()
else
	naughty.notify({
		title = "Networking",
		text = "WiFi off"
	})
end

wireless:connect_signal(function (self, new_state, old_state, state_reason)
	naughty.notify({
		title = "Networking signal",
		text = "State! New: "..new_state..", Old: "..old_state..", Reason: "..state_reason
	})
end, "StateChanged")
