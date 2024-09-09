local aspawn = require("awful.spawn")
local gobject = require("gears.object")
local naughty = require("naughty")

local lgi = require("lgi")
local proxy = require("dbus_proxy")

local pa_server = proxy.Proxy:new({
	bus = proxy.Bus.SESSION,
	name = "org.PulseAudio1",
	path = "/org/pulseaudio/server_lookup1",
	interface = "org.PulseAudio.ServerLookup1"
})

local connection = lgi.Gio.DBusConnection.new_for_address_sync(
	pa_server.Address,
	lgi.Gio.DBusConnectionFlags.AUTHENTICATION_CLIENT
)

local PA_PATH = "/org/pulseaudio/core1"
local PA_IFACE = "org.PulseAudio.Core1"

local core = proxy.Proxy:new({
	bus = connection,
	name = nil,
	path = PA_PATH,
	interface = PA_IFACE
})

local api = { }

function api.object_from_path(path, interface)
	return proxy.Proxy:new({
		bus = connection,
		name = nil,
		path = path,
		interface = interface,
	})
end

setmetatable(api, {
	__index = function (_, k)
		if
			k == "InterfaceRevision" or
			k == "Name" or
			k == "Version" or
			k == "IsLocal" or
			k == "Username" or
			k == "Hostname" or
			k == "DefaultChannels" or
			k == "DefaultSampleFormat" or
			k == "DefaultSampleRate" or
			k == "Cards" or
			k == "Sinks" or
			k == "FallbackSink" or
			k == "Sources" or
			k == "FallbackSource" or
			k == "PlaybackStreams" or
			k == "RecordStreams" or
			k == "Samples" or
			k == "Modules" or
			k == "Clients" or
			k == "MyClient" or
			k == "Extensions"
		then
			return core:Get(PA_IFACE, k)
		end
		local value = core[k]
		if type(value) == "function" then
			return function (...)
				return value(core, ...)
			end
		end
		return value
	end,
	__newindex = function (t, k, v)
		if
			k == "DefaultChannels" or
			k == "DefaultSampleFormat" or
			k == "DefaultSampleRate" or
			k == "FallbackSink" or
			k == "FallbackSource"
		then
			core:Set(PA_IFACE, k, v)
		else
			rawset(t, k, v)
		end
	end
})

function api.Device(path)
	local DEV_IFACE = PA_IFACE .. ".Device"
	local dev_obj = api.object_from_path(path, DEV_IFACE)
	local dev = { }
	setmetatable(dev, {
		__index = function (_, k)
			if
				k == "Index" or
				k == "Name" or
				k == "Driver" or
				k == "OwnerModule" or
				k == "Card" or
				k == "SampleFormat" or
				k == "SampleRate" or
				k == "Channels" or
				k == "Volume" or
				k == "HasFlatVolume" or
				k == "HasConvertibleToDecibelVolume" or
				k == "BaseVolume" or
				k == "VolumeSteps" or
				k == "Mute" or
				k == "HasHardwareVolume" or
				k == "HasHardwareMute" or
				k == "ConfiguredLatency" or
				k == "HasDynamicLatency" or
				k == "Latency" or
				k == "IsHardwareDevice" or
				k == "IsNetworkDevice" or
				k == "State" or
				k == "Ports" or
				k == "ActivePort" or
				k == "PropertyList"
			then
				return dev_obj:Get(DEV_IFACE, k)
			end
			local value = dev_obj[k]
			if type(value) == "function" then
				return function (...)
					return value(dev_obj, ...)
				end
			end
			return value
		end,
		__newindex = function (t, k, v)
			if
				k == "Volume" or
				k == "Mute" or
				k == "ActivePort"
			then
				dev_obj:Set(DEV_IFACE, k, v)
			else
				rawset(t, k, v)
			end
		end
	})
	return dev
end

function api.DevicePort(path)
	local DP_IFACE = PA_IFACE .. ".DevicePort"
	local devport_obj = proxy.Proxy:new({
		bus = connection,
		name = nil,
		path = path,
		interface = DP_IFACE
	})
	local devport = { }
	setmetatable(devport, {
		__index = function (_, k)
			if
				k == "Index" or
				k == "Name" or
				k == "Description" or
				k == "Priority"
			then
				return devport_obj:Get(DP_IFACE, k)
			end
		end
	})
	return devport
end

api.socket = gobject({ class = {} })

return api
