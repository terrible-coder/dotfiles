local aspawn = require("awful.spawn")
local gobject = require("gears.object")

local sound = {
	mute = false,
	volume = 0,
}

sound = gobject({ class = sound })

function sound:change(delta)
	-- if delta == 0 then return end
	-- local volume = self.volume + delta
	-- if volume < 0 or volume > 100 then return end
	if delta < 0 then
		aspawn("pactl set-sink-volume @DEFAULT_SINK@ "..delta.."%")
	else
		aspawn("pactl set-sink-volume @DEFAULT_SINK@ +"..delta.."%")
	end
	-- self.volume = volume
end

function sound:toggle_mute()
	aspawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
	-- self.mute = not self.mute
end

return sound
