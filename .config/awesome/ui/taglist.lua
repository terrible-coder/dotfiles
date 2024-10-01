local Capi = {
	client = client
}
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gtable = require("gears.table")
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
		style = { shape = beautiful.shapes.rounded_small },
		layout = wibox.layout.flex.horizontal,
		widget_template = {
			widget = wibox.container.margin,
			forced_width = dpi(21),
			{
				widget = wibox.container.background, id = "background_role",
				fg = beautiful.taglist_fg,
				shape = beautiful.shapes.rounded_small,
				{
					widget = wibox.widget.textbox, id = "index_role",
					align = "center", valign = "center",
				}
			},
			create_callback = function(self, t, index, _)
				local indexer = self:get_children_by_id("index_role")[1]
				if t.selected then
					self.margins = dpi(2)
					indexer.text = tostring(index)
				elseif #t:clients() == 0 then
					self.margins = dpi(8)
					indexer.text = ""
				else
					self.margins = dpi(4)
					indexer.text = ""
				end
			end,
			update_callback = function(self, t, index, _)
				local indexer = self:get_children_by_id("index_role")[1]
				if t.selected then
					self.margins = dpi(2)
					indexer.text = tostring(index)
				elseif #t:clients() == 0 then
					self.margins = dpi(8)
					indexer.text = ""
				else
					self.margins = dpi(4)
					indexer.text = ""
				end
			end,
		},
	})
end
