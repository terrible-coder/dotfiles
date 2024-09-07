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
local core = proxy.Proxy:new({
	bus = connection,
	name = nil,
	path = "/org/pulseaudio/core1",
	interface = "org.PulseAudio.Core1"
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

function api:change(delta)
	-- if delta == 0 then return end
	-- local volume = self.volume + delta
	-- if volume < 0 or volume > 100 then return end
	if delta < 0 then
		aspawn("pactl set-sink-volume @DEFAULT_SINK@ "..delta.."%")
	else
		aspawn("pactl set-sink-volume @DEFAULT_SINK@ +"..delta.."%")
	end
	-- self.volume = volume
end

function api:toggle_mute()
	aspawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
	-- self.mute = not self.mute
end

api.socket = gobject({ class = {} })

return api
