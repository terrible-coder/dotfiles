local Capi = {
	client = client
}
local awful = require("awful")
local gtable = require("gears.table")
local gshape = require("gears.shape")
local wibox = require("wibox")

local tasklist_buttons = gtable.join(
	awful.button({ }, 1,
		function (c)
			if c == Capi.client.focus then c.minimized = true
			else c:emit_signal("request::activate", "tasklist", { raise = true })
			end
		end),
	awful.button({ }, 3,
		function() awful.menu.client_list({ theme = { width = 250 } }) end)
)

return function(s)
	return awful.widget.tasklist({
		screen  = s,
		filter  = awful.widget.tasklist.filter.minimizedcurrenttags,
		buttons = tasklist_buttons,
		layout = {
			layout = wibox.layout.flex.horizontal,
			spacing = 5
		},
		style = { shape = function(cr, w, h) gshape.rounded_rect(cr, w, h, 2) end },
		widget_template = {
			widget = wibox.container.background,
			id = "background_role",
			{
				widget = wibox.container.margin,
				left = 5, right = 5, top = 2, bottom = 2,
				{
					widget = wibox.widget.imagebox,
					id = "icon_role",
				}
			}
		}
	})
end
