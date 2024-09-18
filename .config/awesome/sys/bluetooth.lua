local proxy = require("dbus_proxy")

local BZ_NAME = "org.bluez"

local bluetooth_device = proxy.Proxy:new({
	bus = proxy.Bus.SYSTEM,
	name = BZ_NAME,
	path = "/org/bluez/hci0",
	interface = "org.freedesktop.DBus.Properties"
})

return bluetooth_device
