local aspawn = require("awful.spawn")
local gtimer = require("gears.timer")
local gobject = require("gears.object")

local battery = {
	level = 0,
	mode = "battery",
	waiting = "0h",
	charging = false,
	health = 100,
}

battery = gobject({ class = battery })

function battery:update()
	aspawn.easy_async("acpi -bi", function(out)
		local level, waiting = out:match("(%d?%d?%d)%%, (%d%d:%d%d:%d%d)")
		level = tonumber(level)
		if level ~= self.level then
			self.level = level
			self.waiting = waiting
			self:emit_signal("battery::update")
		end
		self.health = out:match("mAh = (%d?%d?%d)%%")
	end)
end

battery.timer = gtimer({
	timeout = 10,
	call_now = false,
	autostart = true,
	callback = function() battery:update() end,
})

return battery
