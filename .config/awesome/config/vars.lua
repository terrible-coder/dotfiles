local alayout = require("awful.layout")
local al_suit = alayout.suit

return {
	modkey = "Mod4",
	terminal = "kitty",
	editor = os.getenv("EDITOR") or "editor",
	tags = { "1", "2", "3", "4", "5", "6", "7", "8", "9" },
	layouts = {
		al_suit.tile,
		al_suit.tile.left,
		al_suit.tile.bottom,
		al_suit.tile.top,
		-- al_suit.fair,
		-- al_suit.fair.horizontal,
		-- al_suit.spiral,
		al_suit.spiral.dwindle,
		-- al_suit.max,
		al_suit.max.fullscreen,
		al_suit.floating,
		al_suit.magnifier,
		-- al_suit.corner.nw,
		-- al_suit.corner.ne,
		-- al_suit.corner.sw,
		-- al_suit.corner.se,
	}
}
