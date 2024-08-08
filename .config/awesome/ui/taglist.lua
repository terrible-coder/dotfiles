local Capi = {
	client = client
}
local awful = require("awful")
local gtable = require("gears.table")

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
		buttons = taglist_buttons
	})
end
