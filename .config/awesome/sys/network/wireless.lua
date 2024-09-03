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
local wl_iface = "wlp3s0"
local wireless_path = nm_server:GetDeviceByIpIface(wl_iface)
if not wireless_path then
	local naughty = require("naughty")
	local err = "Could not find wireless device \"%s\". Is it connected?"
	naughty.notify({
		title = "Networking",
		text = err:format(wl_iface),
		preset = naughty.config.presets.critical
	})
	return
end

local wireless = proxy.Proxy:new({
	bus = proxy.Bus.SYSTEM,
	name = NM_NAME,
	path = wireless_path,
	interface = NM_IFACE..".Device"
})

local api = { }

function api.object_from_path(path, interface)
	return proxy.Proxy:new({
		bus = proxy.Bus.SYSTEM,
		name = NM_NAME,
		path = path,
		interface = interface
	})
end

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
		local value = nm_server[k]
		if type(value) == "function" then
			return function (...)
				return value(nm_server, ...)
			end
		end
		return value
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
			return wireless:Get(NM_IFACE..".Device", k)
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
			return wireless:Get(NM_IFACE..".Device.Wireless", k)
		end
		local value = wireless[k]
		if type(value) == "function" then
			return function (...)
				return value(wireless, ...)
			end
		end
		return value
	end
})

function api.AccessPoint(path, dont_listen)
	local AP_IFACE = NM_IFACE..".AccessPoint"
	local ap_obj = api.object_from_path(path, AP_IFACE)
	if not dont_listen then
		ap_obj:on_properties_changed(function(_, changed, _)
			api.socket:emit_signal("AccessPoint::PropertiesChanged", path, changed)
		end)
	end
	local ap = { }
	setmetatable(ap, {
		__index = function (_, k)
			if
				k == "Flags" or
				k == "WpaFlags" or
				k == "RsnFlags" or
				k == "Ssid" or
				k == "Frequency" or
				k == "HwAddress" or
				k == "Mode" or
				k == "MaxBitrate" or
				k == "Bandwidth" or
				k == "Strength" or
				k == "LastSeen"
			then
				return ap_obj:Get(AP_IFACE, k)
			end
			local value = wireless[k]
			if type(value) == "function" then
				return function (...)
					return value(ap_obj, ...)
				end
			end
			return value
		end
	})
	return ap
end

api.socket = require("gears.object")({ class = {} })

wireless:connect_signal(function (_, new_state, old_state, state_reason)
	api.socket:emit_signal("StateChanged", {
		new = new_state, old = old_state, reason = state_reason
	})
end, "StateChanged")

return api
