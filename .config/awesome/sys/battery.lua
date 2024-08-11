local aspawn = require("awful.spawn")
local gtimer = require("gears.timer")

local battery = {
	level = 0,
	mode = "battery",
	waiting = "0h",
	charging = false,
	health = 100,
	callbacks = { }
}

function battery:sync(cback)
	table.insert(self.callbacks, cback)
end

function battery:client_update()
	for _, cback in pairs(self.callbacks) do
		cback(self.mode, self.level, self.charging)
	end
end

function battery:update()
	aspawn.easy_async("acpi -bi", function(out)
		local level, waiting = out:match("(%d?%d?%d)%%, (%d%d:%d%d:%d%d)")
		level = tonumber(level)
		if level ~= self.level then
			self.level = level
			self.waiting = waiting
			self:client_update()
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
