---------------------------
-- Default awesome theme --
---------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local gfs = require("gears.filesystem")
local gshape = require("gears.shape")
local themes_path = gfs.get_themes_dir()

local theme = { }
theme.fonts = {
	sans  = "Helvetica ",
	serif = "Dejavu Serif ",
	nerd = "Hack Nerd Font Mono ",
	mono  = "mononoki ",
	weather = "Weather Icons ",
}
theme.font = theme.fonts.sans..10

theme.colors = require("themes.rosepine.colors").rosepine.main
theme.shapes = {
	rounded_small = function(cr, w, h)
		gshape.rounded_rect(cr, w, h, dpi(2))
	end,
	rounded_large = function(cr, w, h)
		gshape.rounded_rect(cr, w, h, dpi(5))
	end,
}
theme.bg_normal     = theme.colors.base
theme.bg_focus      = theme.colors.pine
theme.bg_urgent     = theme.colors.love
theme.bg_minimize   = theme.colors.muted
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = theme.colors.text
theme.fg_focus      = theme.colors.base
theme.fg_urgent     = theme.colors.hl_low
theme.fg_minimize   = "#ffffff"

theme.useless_gap   = dpi(5)
theme.border_width  = dpi(2)
theme.border_normal = theme.colors.base.."00"
theme.border_focus  = theme.colors.gold
theme.border_marked = theme.colors.pine

theme.taglist_bg          = theme.colors.surface
theme.taglist_bg_focus    = theme.colors.rose
theme.taglist_bg_urgent   = theme.colors.gold
theme.taglist_bg_occupied = theme.colors.subtle
theme.taglist_bg_empty    = theme.colors.muted

theme.taglist_fg          = theme.colors.surface
theme.taglist_fg_focus    = theme.colors.surface
-- theme.taglist_fg_urgent   = theme.colors.gold
-- theme.taglist_fg_occupied = theme.colors.text
-- theme.taglist_fg_empty    = theme.colors.muted

theme.tooltip_bg = theme.colors.overlay
theme.tooltip_fg = theme.colors.text
theme.tooltip_shape = theme.shapes.rounded_small
theme.tooltip_border_width = dpi(2)
theme.tooltip_border_color = theme.colors.iris

theme.hotkeys_shape = theme.shapes.rounded_large
theme.hotkeys_border_width = dpi(2)
theme.hotkeys_border_color = theme.colors.pine
theme.hotkeys_modifiers_fg = theme.colors.gold

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]

-- Variables set for theming notifications:
-- notification_font
theme.notification_bg = theme.colors.overlay
theme.notification_shape = theme.shapes.rounded_large
theme.notification_border_width = dpi(2)
theme.notification_border_color = theme.colors.iris

-- Variables set for theming the menu:
theme.menu_submenu_icon = themes_path.."rosepine/submenu.png"
theme.menu_height = dpi(25)
theme.menu_width  = dpi(150)
theme.menu_border_width = dpi(2)
theme.menu_border_color = theme.colors.iris
theme.menu_bg_focus = theme.colors.iris

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

theme.wallpaper = themes_path.."rosepine/background.png"

-- You can use your own layout icons like this:
theme.layout_fairh = themes_path.."rosepine/layouts/fairhw.png"
theme.layout_fairv = themes_path.."rosepine/layouts/fairvw.png"
theme.layout_floating  = themes_path.."rosepine/layouts/floatingw.png"
theme.layout_magnifier = themes_path.."rosepine/layouts/magnifierw.png"
theme.layout_max = themes_path.."rosepine/layouts/maxw.png"
theme.layout_fullscreen = themes_path.."rosepine/layouts/fullscreenw.png"
theme.layout_tilebottom = themes_path.."rosepine/layouts/tilebottomw.png"
theme.layout_tileleft   = themes_path.."rosepine/layouts/tileleftw.png"
theme.layout_tile = themes_path.."rosepine/layouts/tilew.png"
theme.layout_tiletop = themes_path.."rosepine/layouts/tiletopw.png"
theme.layout_spiral  = themes_path.."rosepine/layouts/spiralw.png"
theme.layout_dwindle = themes_path.."rosepine/layouts/dwindlew.png"
theme.layout_cornernw = themes_path.."rosepine/layouts/cornernww.png"
theme.layout_cornerne = themes_path.."rosepine/layouts/cornernew.png"
theme.layout_cornersw = themes_path.."rosepine/layouts/cornersww.png"
theme.layout_cornerse = themes_path.."rosepine/layouts/cornersew.png"

-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

return theme
