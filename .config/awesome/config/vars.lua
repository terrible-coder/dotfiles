local alayout = require("awful.layout")

return {
	modkey = "Mod4",
	terminal = "kitty",
	editor = os.getenv("EDITOR") or "editor",
	tags = { "1", "2", "3", "4", "5", "6", "7", "8", "9" },
	layouts = {
		alayout.suit.tile,
		alayout.suit.tile.left,
		alayout.suit.tile.bottom,
		alayout.suit.tile.top,
		-- alayout.suit.fair,
		-- alayout.suit.fair.horizontal,
		-- alayout.suit.spiral,
		alayout.suit.spiral.dwindle,
		-- alayout.suit.max,
		alayout.suit.max.fullscreen,
		alayout.suit.floating,
		alayout.suit.magnifier,
		-- alayout.suit.corner.nw,
		-- alayout.suit.corner.ne,
		-- alayout.suit.corner.sw,
		-- alayout.suit.corner.se,
	}
}
