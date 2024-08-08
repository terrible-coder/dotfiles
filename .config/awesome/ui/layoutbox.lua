local awful = require("awful")
local gtable = require("gears.table")

return function(s)
	local lbox = awful.widget.layoutbox(s)
	lbox:buttons(gtable.join(
		awful.button({ }, 1, function () awful.layout.inc( 1) end),
		awful.button({ }, 3, function () awful.layout.inc(-1) end),
		awful.button({ }, 4, function () awful.layout.inc( 1) end),
		awful.button({ }, 5, function () awful.layout.inc(-1) end))
	)
	return lbox
end
