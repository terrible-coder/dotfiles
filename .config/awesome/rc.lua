-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

-- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({ preset = naughty.config.presets.critical,
					 title = "Oops, there were errors during startup!",
					 text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
		-- Make sure we don't go into an endless error loop
		if in_error then return end
		in_error = true

		naughty.notify({ preset = naughty.config.presets.critical,
						 title = "Oops, an error happened!",
						 text = tostring(err) })
		in_error = false
	end)
end
-- }}}

-- {{{ Variable definitions
local vars = require("config.vars")
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = vars.layouts
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
local myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", vars.terminal }

if has_fdo then
	mymainmenu = freedesktop.menu.build({
		before = { menu_awesome },
		after =  { menu_terminal }
	})
else
	mymainmenu = awful.menu({
		items = {
				  menu_awesome,
				  { "Debian", debian.menu.Debian_menu.Debian },
				  menu_terminal,
				}
	})
end


local mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
									 menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = vars.terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
local mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
local mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it

local function set_wallpaper(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

local layoutbox = require("ui.layoutbox")
local tasklist = require("ui.tasklist")
local taglist = require("ui.taglist")
local widgets = require("ui.widgets")

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Each screen has its own tag table.
	awful.tag(vars.tags, s, awful.layout.layouts[1])

	-- Create a promptbox for each screen
	local mypromptbox = awful.widget.prompt()
	s.mypromptbox = mypromptbox
	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	local mylayoutbox = layoutbox(s)
	local mytaglist = taglist(s)
	local mytasklist = tasklist(s)

	-- Create the wibox
	local mywibox = awful.wibar({ position = "top", screen = s })
	mywibox:setup {
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			mylauncher,
			mytaglist,
			mypromptbox,
		},
		mytasklist, -- Middle widget
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			widgets.volume,
			mykeyboardlayout,
			wibox.widget.systray(),
			mytextclock,
			mylayoutbox,
		},
	}
end)
-- }}}

local binds = require("binds")
root.keys(binds.global.keys)
root.buttons(binds.global.buttons)

require("config.rules")

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup
	  and not c.size_hints.user_position
	  and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
--

gears.timer({
	timeout = 60,
	autostart = true,
	callback = function()
		collectgarbage("collect")
		collectgarbage("collect")
	end
})
