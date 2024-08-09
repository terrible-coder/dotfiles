local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local keyboardlayout = awful.widget.keyboardlayout()
local textclock = wibox.widget.textclock()
local launcher = awful.widget.launcher({
	image = beautiful.awesome_icon,
	menu = require("ui.menu")
})

local layoutbox = require("ui.layoutbox")
local tasklist  = require("ui.tasklist")
local taglist   = require("ui.taglist")
local widgets   = require("ui.widgets")

return function(s)
	local promptbox = awful.widget.prompt()
	s.promptbox = promptbox -- i did not want to do this but too much work to fix
	local master_bar = awful.wibar({ position = "top", screen = s })
	master_bar:setup {
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			launcher,
			taglist(s),
			promptbox,
		},
		tasklist(s), -- Middle widget
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			widgets.brightness,
			widgets.volume,
			keyboardlayout,
			wibox.widget.systray(),
			textclock,
			layoutbox(s),
		},
	}
end
