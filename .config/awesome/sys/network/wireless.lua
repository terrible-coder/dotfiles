local naughty = require("naughty")
local proxy = require("dbus_proxy")

local enums = require(... .. ".enums")

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

setmetatable(api, {
	__index = function (_, k)
		if
			k == "Devices" or
			k == "AllDevices" or
			k == "Checkpoints" or
			k == "NetworkingEnabled" or
			k == "WirelessEnabled" or
			k == "WirelessHardwareEnabled" or
			k == "WwanEnabled" or
			k == "WwanHardwareEnabled" or
			-- k == "WimaxEnabled" or --DEPRECATED
			-- k == "WimaxHardwareEnabled" or -- DEPRECATED
			k == "RadioFlags" or
			k == "ActiveConnections" or
			k == "PrimaryConnection" or
			k == "PrimaryConnectionType" or
			k == "Metered" or
			k == "ActivatingConnection" or
			k == "Startup" or
			k == "Version" or
			k == "VersionInfo" or
			k == "Capabilities" or
			k == "State" or
			k == "Connectivity" or
			k == "ConnectivityCheckAvailable" or
			k == "ConnectivityCheckEnabled" or
			k == "ConnectivityCheckUri" or
			k == "GlobalDnsConfiguration"
		then
			return nm_server:Get(NM_IFACE, k)
		end
		return nil
	end
})

--[[
	This is the wireless Device manager. It implements the interfaces
	"org.freedesktop.NetworkManager.Device" as well as
	"org.freedesktop.NetworkManager.Device.Wireless". Properties from both
	interfaces can be accessed through this object.
]]
api.Device = { }
setmetatable(api.Device, {
	__index = function (_, k)
		-- Properties implemented from "org.freedesktop.NetworkManager.Device"
		if
			k == "Udi" or
			k == "Path" or
			k == "Interface" or
			k == "IpInterface" or
			k == "Driver" or
			k == "DriverVersion" or
			k == "FirmwareVersion" or
			k == "Capabilities" or
			-- k == "Ip4Address" or -- DEPRECATED
			k == "State" or
			k == "StateReason" or
			k == "ActiveConnection" or
			k == "Ip4Config" or
			k == "Dhcp4Config" or
			k == "Ip6Config" or
			k == "Dhcp6Config" or
			k == "Managed" or
			k == "Autoconnect" or
			k == "FirmwareMissing" or
			k == "NmPluginMissing" or
			k == "DeviceType" or
			k == "AvailableConnections" or
			k == "PhysicalPortId" or
			k == "Mtu" or
			k == "Metered" or
			k == "LldpNeighbors" or
			k == "Real" or
			k == "Ip4Connectivity" or
			k == "Ip6Connectivity" or
			k == "InterfaceFlags" or
			k == "HwAddress" or
			k == "Ports"
		then
			return api.device:Get(NM_IFACE..".Device", k)
		end
		-- Properties implemented from
		-- "org.freedesktop.NetworkManager.Device.Wireless"
		if
			-- k == "HwAddress" or -- DEPRECATED
			k == "PermHwAddress" or
			k == "Mode" or
			k == "Bitrate" or
			k == "AccessPoints" or
			k == "ActiveAccessPoint" or
			k == "WirelessCapabilities" or
			k == "LastScan"
		then
			return api.device:Get(NM_IFACE..".Device.Wireless", k)
		end
	end
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
api.device = proxy.Proxy:new({
	bus = proxy.Bus.SYSTEM,
	name = NM_NAME,
	path = wireless_path,
	interface = NM_IFACE..".Device"
})

function api.Get_ActiveAccessPoint()
	local active_ap_path = api.Device.ActiveAccessPoint
	naughty.notify({ title = "Networking", text = "Active AP: "..active_ap_path })
	api.active_ap = proxy.Proxy:new({
		bus = proxy.Bus.SYSTEM,
		name = NM_NAME,
		path = active_ap_path,
		interface = NM_IFACE..".AccessPoint"
	})
end

local function refresh_state()
	if api.Device.State == enums.DeviceState.ACTIVATED then
		api.Get_ActiveAccessPoint()
		naughty.notify({
			title = "Networking",
			text = "Current AP: "..string.char(table.unpack(api.active_ap.Ssid))
		})
	else
		api.active_ap = nil
		if api.WirelessEnabled then
			naughty.notify({
				title = "Networking",
				text = "Disconnected",
			})
		else
			naughty.notify({
				title = "Networking",
				text = "WiFi off"
			})
		end
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
