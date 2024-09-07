local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-- local keyboardlayout = awful.widget.keyboardlayout()
local textclock = wibox.widget.textclock("%H:%M")
local launcher = awful.widget.launcher({
	image = beautiful.awesome_icon,
	menu = require("ui.menu")
})

local layoutbox = require("ui.layoutbox")
local tasklist  = require("ui.tasklist")
local taglist   = require("ui.taglist")
local widgets   = require("ui.widgets")

local separator = wibox.widget({
	widget = wibox.widget.separator,
	orientation = "vertical",
	forced_width = 5,
})

return function(s)
	local promptbox = awful.widget.prompt()
	s.promptbox = promptbox -- i did not want to do this but too much work to fix
	local master_bar = awful.wibar({
		position = "top", screen = s,
		height = dpi(25),
	})
	master_bar:setup({
		widget = wibox.container.margin,
		margins = dpi(2),
		{
			layout = wibox.layout.align.horizontal,
			expand = "none",
			{ -- Left widgets
				layout = wibox.layout.fixed.horizontal,
				spacing = 10,
				launcher,
				tasklist(s), -- Middle widget
				promptbox,
			},
			taglist(s),
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			spacing = 5,
			widgets.network,
			separator,
			widgets.brightness,
			widgets.volume,
			separator,
			widgets.battery,
			-- keyboardlayout,
			wibox.widget.systray(),
			textclock,
			layoutbox(s),
		},
	}
})
end
