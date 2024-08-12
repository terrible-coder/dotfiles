local aspawn = require("awful.spawn")
local gtimer = require("gears.timer")
local gobject = require("gears.object")

local backlight = {
	level = 0,
}
backlight = gobject({ class = backlight })

function backlight:change(delta)
	if delta == 0 then return end
	local level = self.level + delta
	if level < 0 or level > 100 then return end
	if delta < 0 then
		aspawn("brightnessctl set "..(-delta).."%-")
	else
		aspawn("brightnessctl set "..delta.."%+")
	end
	self.level = level
	self:emit_signal("backlight::update")
end

function backlight:update()
	aspawn.easy_async(
		"brightnessctl info",
		function(out)
			local level = tonumber(out:match("(%d?%d%d)%%"))
			if level ~= self.level then
				self.level = level
				self:emit_signal("backlight::update")
			end
		end
	)
end

gtimer({
	timeout = 2,
	autostart = true,
	single_shot = true,
	callback = function() backlight:update() end
})

return backlight
