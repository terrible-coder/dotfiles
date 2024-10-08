local lgi = require("lgi")
local GLib, Gio = lgi.GLib, lgi.Gio
local dbus = require("modules.dbus-lua")

local objects = { }

-- preparing wifi object

local NM_IFACE = "org.freedesktop.NetworkManager"
local NM_NAME = "org.freedesktop.NetworkManager"
local IP_IFACE = "wlp3s0"

local nm_proxy = dbus.Proxy.new(dbus.ObjectProxy.new(
	dbus.Bus.SYSTEM,
	"/org/freedesktop/NetworkManager",
	"org.freedesktop.NetworkManager"
), NM_NAME)
local all_connections = dbus.ObjectProxy.new(
	dbus.Bus.SYSTEM,
	"/org/freedesktop/NetworkManager/Settings",
	NM_NAME
):implement(NM_IFACE..".Settings").Connections
local known = { }
for _, conn_path in ipairs(all_connections) do
	local settings = dbus.ObjectProxy.new(
		dbus.Bus.SYSTEM,
		conn_path,
		NM_NAME
	):implement(NM_IFACE..".Settings.Connection"):GetSettings()
	local deviface = settings.connection["interface-name"]
	local id = settings.connection["id"]
	if deviface == IP_IFACE then
		known[#known+1] = { connection = conn_path, id = id, available = false }
	end
end
objects.wifi = {
	server = nm_proxy,
	object = dbus.ObjectProxy.new(
		dbus.Bus.SYSTEM,
		nm_proxy:GetDeviceByIpIface(IP_IFACE),
		NM_NAME
	),
	known_connections = known,
	base = NM_IFACE,
	enums = {
		DeviceState = {
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
	}
}

-- preparing PulseAudio object

local address = dbus.Bus.SESSION:call_sync(
	"org.PulseAudio1",
	"/org/pulseaudio/server_lookup1",
	"org.freedesktop.DBus.Properties",
	"Get",
	GLib.Variant.new("(ss)", { "org.PulseAudio.ServerLookup1" , "Address" }),
	GLib.VariantType.new("(v)"),
	Gio.DBusCallFlags.NONE,
	-1
)
address = dbus.Variant.unpack(address)[1]
local connection = Gio.DBusConnection.new_for_address_sync(
	address, Gio.DBusConnectionFlags.AUTHENTICATION_CLIENT, nil
)

local PA_PATH = "/org/pulseaudio/core1"
objects.pulse = {
	object = dbus.ObjectProxy.new(connection, PA_PATH, nil),
	base = "org.PulseAudio.Core1",
	enums = {
		Available = {
			UNKNOWN = 0,
			NO = 1,
			YES = 2,
		},
	}
}

-- prepare bluez bluetooth object

local BT_PATH = "/org/bluez/hci0"
objects.bluetooth = {
	object = dbus.ObjectProxy.new(dbus.Bus.SYSTEM, BT_PATH, "org.bluez"),
	base = "org.bluez"
}

return objects
