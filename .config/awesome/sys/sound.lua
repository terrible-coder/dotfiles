local aspawn = require("awful.spawn")
local gtimer = require("gears.timer")
local gobject = require("gears.object")

local sound = {
	mute = false,
	volume = 0,
}

sound = gobject({ class = sound })

function sound:change(delta)
	if delta == 0 then return end
	local volume = self.volume + delta
	if volume < 0 or volume > 100 then return end
	if delta < 0 then
		aspawn("pactl set-sink-volume @DEFAULT_SINK@ "..delta.."%")
	else
		aspawn("pactl set-sink-volume @DEFAULT_SINK@ +"..delta.."%")
	end
	self.volume = volume
	self:emit_signal("sound::update")
end

function sound:toggle_mute()
	aspawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
	self.mute = not self.mute
	self:emit_signal("sound::update")
end

function sound:update()
	aspawn.easy_async(
		"pactl list sinks",
		function(out)
			local volume = tonumber(out:match("(.%d%d)%%"))
			if volume ~= self.volume then
				self.volume = volume
				self:emit_signal("sound::update")
			end
			-- local lines = { }
			-- local i = 1
			-- for s in out:gmatch("[^\r\n]+") do
			-- 	lines[i] = s
			-- 	i = i + 1
			-- end
		end
	)
end

sound.timer = gtimer({
	timeout = 10,
	autostart = true,
	callback = function()
		sound:update()
	end
})

return sound
