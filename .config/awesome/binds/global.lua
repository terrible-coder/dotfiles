local Capi = {
	awesome = awesome,
	client = client,
}
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")
local gears = require("gears")

local vars = require("config.vars")
local blight = require("sys.backlight")
local menu = require("ui.menu")
local modkey = vars.modkey
local terminal = vars.terminal


local global_keys = gears.table.join(
	awful.key(
		{ modkey }, "s",hotkeys_popup.show_help,
		{ description="show help", group="awesome" }
	),
	awful.key(
		{ modkey }, "Left", awful.tag.viewprev,
		{ description = "view previous", group = "tag" }
	),
	awful.key(
		{ modkey }, "Right", awful.tag.viewnext,
		{ description = "view next", group = "tag" }
	),
	awful.key(
		{ modkey }, "Escape", awful.tag.history.restore,
		{ description = "go back", group = "tag" }
	),

	awful.key(
		{ modkey }, "j",
		function ()
			awful.client.focus.byidx( 1)
		end,
		{ description = "focus next by index", group = "client" }
	),
	awful.key(
		{ modkey }, "k",
		function ()
			awful.client.focus.byidx(-1)
		end,
		{ description = "focus previous by index", group = "client" }
	),
	awful.key(
		{ modkey }, "w", function () menu:show() end,
		{ description = "show main menu", group = "awesome" }
	),

	-- Layout manipulation
	awful.key(
		{ modkey, "Shift" }, "j", function () awful.client.swap.byidx(1)	end,
		{ description = "swap with next client by index", group = "client" }
	),
	awful.key(
		{ modkey, "Shift" }, "k", function () awful.client.swap.byidx( -1)	end,
		{ description = "swap with previous client by index", group = "client" }
	),
	awful.key(
		{ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
		{ description = "focus the next screen", group = "screen" }
	),
	awful.key(
		{ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
		{ description = "focus the previous screen", group = "screen" }
	),
	awful.key(
		{ modkey }, "u", awful.client.urgent.jumpto,
		{ description = "jump to urgent client", group = "client" }
	),
	awful.key(
		{ modkey }, "Tab",
		function ()
			awful.client.focus.history.previous()
			if Capi.client.focus then
				Capi.client.focus:raise()
			end
		end,
		{ description = "go back", group = "client" }
	),

	-- Standard program
	awful.key(
		{ modkey }, "Return",
		function () awful.spawn(terminal) end,
		{ description = "open a terminal", group = "launcher" }
	),
	awful.key(
		{ modkey, "Control" }, "r", Capi.awesome.restart,
		{ description = "reload awesome", group = "awesome" }
	),
	awful.key(
		{ modkey, "Shift" }, "q", Capi.awesome.quit,
		{ description = "quit awesome", group = "awesome" }
	),

	awful.key(
		{ modkey }, "l", function () awful.tag.incmwfact( 0.05)		end,
		{ description = "increase master width factor", group = "layout" }
	),
	awful.key(
		{ modkey }, "h", function () awful.tag.incmwfact(-0.05)		end,
		{ description = "decrease master width factor", group = "layout" }
	),
	awful.key(
		{ modkey, "Shift" }, "h", function () awful.tag.incnmaster( 1, nil, true) end,
		{ description = "increase the number of master clients", group = "layout" }
	),
	awful.key(
		{ modkey, "Shift" }, "l", function () awful.tag.incnmaster(-1, nil, true) end,
		{ description = "decrease the number of master clients", group = "layout" }
	),
	awful.key(
		{ modkey, "Control" }, "h", function () awful.tag.incncol( 1, nil, true)	end,
		{ description = "increase the number of columns", group = "layout" }
	),
	awful.key(
		{ modkey, "Control" }, "l", function () awful.tag.incncol(-1, nil, true)	end,
		{ description = "decrease the number of columns", group = "layout" }
	),
	awful.key(
		{ modkey }, "space", function () awful.layout.inc( 1) end,
		{ description = "select next", group = "layout" }
	),
	awful.key(
		{ modkey, "Shift" }, "space", function () awful.layout.inc(-1) end,
		{ description = "select previous", group = "layout" }
	),

	awful.key(
		{ modkey, "Control" }, "n",
			function ()
				local c = awful.client.restore()
				-- Focus restored client
				if c then
					c:emit_signal(
						"request::activate", "key.unminimize", {raise = true}
					)
				end
			end,
	{ description = "restore minimized", group = "client" }
	),

	-- Prompt
	awful.key(
		{ modkey }, "r", function () awful.screen.focused().promptbox:run() end,
		{ description = "run prompt", group = "launcher" }
	),

	awful.key(
		{ modkey }, "x",
		function ()
			awful.prompt.run {
				prompt	 = "Run Lua code: ",
				textbox	= awful.screen.focused().promptbox.widget,
				exe_callback = awful.util.eval,
				history_path = awful.util.get_cache_dir() .. "/history_eval"
			}
		end,
		{ description = "lua execute prompt", group = "awesome" }
	),
	-- Menubar
	awful.key(
		{ modkey }, "p", function() require("menubar").show() end,
		{ description = "show the menubar", group = "launcher" }
	),
	awful.key(
		{ modkey }, "b", function() awful.spawn("waterfox") end,
		{ description = "launch browser", group = "launcher" }
	)
)

for i = 1, 9 do
	global_keys = gears.table.join(global_keys,
		-- View tag only.
		awful.key(
			{ modkey }, "#" .. i + 9,
				function ()
						local screen = awful.screen.focused()
						local tag = screen.tags[i]
						if tag then
						 tag:view_only()
						end
				end,
			{ description = "view tag #"..i, group = "tag" }
		),
		-- Toggle tag display.
		awful.key(
			{ modkey, "Control" }, "#" .. i + 9,
			function ()
				local screen = awful.screen.focused()
				local tag = screen.tags[i]
				if tag then
					awful.tag.viewtoggle(tag)
				end
			end,
			{ description = "toggle tag #" .. i, group = "tag" }
		),
		-- Move client to tag.
		awful.key(
			{ modkey, "Shift" }, "#" .. i + 9,
			function ()
				if Capi.client.focus then
					local tag = Capi.client.focus.screen.tags[i]
					if tag then
						Capi.client.focus:move_to_tag(tag)
					end
				end
			end,
			{ description = "move focused client to tag #"..i, group = "tag" }
		),
		-- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
		function ()
			if Capi.client.focus then
				local tag = Capi.client.focus.screen.tags[i]
				if tag then
					Capi.client.focus:toggle_tag(tag)
				end
			end
		end,
		{ description = "toggle focused client on tag #" .. i, group = "tag" })
	)
end

local global_buttons = gears.table.join(
	awful.button({ }, 3, function () menu:toggle() end),
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev)
)

global_keys = gears.table.join(global_keys,
	awful.key({ }, "XF86AudioMute", function()
		awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
	end),
	awful.key({ }, "XF86AudioLowerVolume", function()
		awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")
	end),
	awful.key({ }, "XF86AudioRaiseVolume", function()
		awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")
	end),
	awful.key({ "Shift" }, "XF86AudioMute", function()
		awful.spawn("pactl set-source-mute @DEFAULT_SOURCE@ toggle")
	end),
	awful.key({ "Shift" }, "XF86AudioLowerVolume", function()
		awful.spawn("pactl set-source-volume @DEFAULT_SOURCE@ -5%")
	end),
	awful.key({ "Shift" }, "XF86AudioRaiseVolume", function()
		awful.spawn("pactl set-source-volume @DEFAULT_SOURCE@ +5%")
	end),
	awful.key({ }, "XF86MonBrightnessDown", function() blight:change(-5) end),
	awful.key({ }, "XF86MonBrightnessUp", function() blight:change( 5) end)
)

return {
	keys = global_keys,
	buttons = global_buttons
}
