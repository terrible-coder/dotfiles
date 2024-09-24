local lgi = require("lgi")
local GLib, Gio = lgi.GLib, lgi.Gio
local dbus = require("modules.dbus-lua")

local objects = { }

-- preparing wifi object

local NM_IFACE = "org.freedesktop.NetworkManager"
local NM_NAME = "org.freedesktop.NetworkManager"
local nm_proxy = dbus.Proxy.new(dbus.ObjectProxy.new(
	dbus.Bus.SYSTEM,
	"/org/freedesktop/NetworkManager",
	"org.freedesktop.NetworkManager"
), NM_NAME)
objects.wifi = {
	object = dbus.ObjectProxy.new(
		dbus.Bus.SYSTEM,
		nm_proxy:GetDeviceByIpIface("wlp3s0"),
		NM_NAME
	),
	base = NM_IFACE,
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
}

-- prepare bluez bluetooth object

local BT_PATH = "/org/bluez/hci0"
objects.bluetooth = {
	object = dbus.ObjectProxy.new(dbus.Bus.SYSTEM, BT_PATH, "org.bluez"),
	base = "org.bluez"
}

return objects
