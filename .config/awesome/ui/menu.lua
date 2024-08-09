local Capi = {
	awesome = awesome,
}
local awful = require("awful")
local beautiful = require("beautiful")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

local vars = require("config.vars")

local main = { }

local menu_awesome = {
	"awesome",
	{
		{ "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
		{ "restart", Capi.awesome.restart },
		{ "quit", function() Capi.awesome.quit() end },
	},
	beautiful.awesome_icon
}
local menu_terminal = { "open terminal", vars.terminal }

if has_fdo then
	main = freedesktop.menu.build({
		before = { menu_awesome },
		after =  { menu_terminal }
	})
else
	main = awful.menu({
		items = {
			menu_awesome,
			{ "Debian", debian.menu.Debian_menu.Debian },
			menu_terminal,
		}
	})
end

return main
