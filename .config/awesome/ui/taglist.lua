local Capi = {
	client = client
}
local awful = require("awful")
local gtable = require("gears.table")
local gshape = require("gears.shape")
local wibox = require("wibox")

local modkey = require("config.vars").modkey

local taglist_buttons = gtable.join(
	awful.button({ }, 1, function(t) t:view_only() end),
	awful.button({ modkey }, 1, function(t)
		if Capi.client.focus then
			Capi.client.focus:move_to_tag(t)
		end
	end),
	awful.button({ }, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if Capi.client.focus then
			Capi.client.focus:toggle_tag(t)
		end
	end)
)

return function(s)
	return awful.widget.taglist({
		screen  = s,
		filter  = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
		style = { shape = function(cr, w, h) gshape.rounded_rect(cr, w, h, 2) end },
		layout = {
			layout = wibox.layout.flex.horizontal,
			spacing = 2,
		},
		widget_template = {
			widget = wibox.container.background,
			id = "background_role",
			{
				widget = wibox.container.margin,
				left = 10, right = 10,
				{
					widget = wibox.widget.textbox,
					id = "text_role",
				},
			},
		}
	})
end
