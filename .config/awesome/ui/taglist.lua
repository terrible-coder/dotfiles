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
		layout = wibox.layout.flex.horizontal,
		widget_template = {
			widget = wibox.container.margin,
			forced_width = 20,
			{
				widget = wibox.container.background, id = "container",
				fg = "#ffffff",
				shape = function(cr, w, h) gshape.rounded_rect(cr, w, h, 2) end,
				{
					widget = wibox.widget.textbox, id = "index",
					align = "center", valign = "center",
				}
			},
			create_callback = function(self, t, index, _)
				local container = self:get_children_by_id("container")[1]
				local indexer = self:get_children_by_id("index")[1]
				if t.selected then
					self.margins = 2
					container.bg = "#00aab0"
					indexer.text = tostring(index)
				elseif #t:clients() == 0 then
					self.margins = 8
					container.bg = "#3f3f3f"
					indexer.text = ""
				else
					self.margins = 3
					container.bg = "#000000"
					indexer.text = ""
				end
			end,
			update_callback = function(self, t, index, _)
				local container = self:get_children_by_id("container")[1]
				local indexer = self:get_children_by_id("index")[1]
				if t.selected then
					self.margins = 2
					container.bg = "#00aab0"
					indexer.text = tostring(index)
				elseif #t:clients() == 0 then
					self.margins = 8
					container.bg = "#3f3f3f"
					indexer.text = ""
				else
					self.margins = 3
					container.bg = "#000000"
					indexer.text = ""
				end
			end,
		},
	})
end
