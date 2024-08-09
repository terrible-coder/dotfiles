local aspawn = require("awful.spawn")
local gtimer = require("gears.timer")

local backlight = {
	level = 0,
	callbacks = { }
}

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
	self:client_update()
end

function backlight:sync(cback)
	table.insert(self.callbacks, cback)
	cback(self.level)
end

function backlight:client_update()
	for _, cback in pairs(self.callbacks) do
		cback(self.level)
	end
end

function backlight:update()
	aspawn.easy_async(
		"brightnessctl info",
		function(out)
			local level = tonumber(out:match("(%d?%d%d)%%"))
			if level ~= self.level then
				self.level = level
				self:client_update()
			end
		end
	)
end

backlight.timer = gtimer({
	timeout = 10,
	autostart = true,
	callback = function()
		backlight:update()
	end
})

return backlight
