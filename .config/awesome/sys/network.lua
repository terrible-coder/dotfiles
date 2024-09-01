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

local api = { }
api.Device_State = {
	UNKNOWN      =   0,
	UNMANAGED    =  10,
	UNAVAILABLE  =  20,
	DISCONNECTED =  30,
	PREPARE      =  40,
	CONFIG       =  50,
	NEED_AUTH    =  60,
	IP_CONFIG    =  70,
	IP_CHECK     =  80,
	SECONDARIES  =  90,
	ACTIVATED    = 100,
	DEACTIVATING = 110,
	FAILED       = 120,
}

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
api.device = proxy.Proxy:new({
	bus = proxy.Bus.SYSTEM,
	name = NM_NAME,
	path = wireless_path,
	interface = NM_IFACE..".Device"
})

function api.Get_ActiveAccessPoint(wireless)
	local active_ap_path = wireless:Get(NM_IFACE..".Device.Wireless", "ActiveAccessPoint")
	naughty.notify({ title = "Networking", text = "Active AP: "..active_ap_path })
	api.active_ap = proxy.Proxy:new({
		bus = proxy.Bus.SYSTEM,
		name = NM_NAME,
		path = active_ap_path,
		interface = NM_IFACE..".AccessPoint"
	})
end

local function refresh_state()
	if api.device:Get(NM_IFACE..".Device", "State") == 100 then
		api.Get_ActiveAccessPoint(api.device)
		naughty.notify({
			title = "Networking",
			text = "Current AP: "..string.char(table.unpack(api.active_ap.Ssid))
		})
	else
		api.active_ap = nil
		naughty.notify({
			title = "Networking",
			text = "WiFi off"
		})
	end
end
refresh_state()

api.device:connect_signal(function (self, new_state, old_state, state_reason)
	naughty.notify({
		title = "Networking signal",
		text = "State! New: "..new_state..", Old: "..old_state..", Reason: "..state_reason
	})
	refresh_state()
end, "StateChanged")

return api
