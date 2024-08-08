local Capi = {
	client = client
}
local awful = require("awful")
local gtable = require("gears.table")

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
		buttons = tasklist_buttons
	})
end
