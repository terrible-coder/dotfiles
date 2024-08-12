local aspawn = require("awful.spawn")
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
		self.health = tonumber(out:match("mAh = (%d?%d?%d)%%"))
	end)
	aspawn.with_line_callback(
		[[bash -c "
			while true; do acpi -b | sed 's/Battery [0-9]\+:\s\+//'; sleep 10; done
		"]],
		{
			stdout = function(out)
				self.charging = out:sub(1, 1)
				local level = tonumber(out:match("(%d?%d?%d)%%"))
				local waiting = out:match("(%d%d:%d%d:%d%d)")
				if level ~= self.level then
					self.level = level
					if not waiting then
						self.waiting = "--:--:--"
					else
						self.waiting = waiting
					end
					self:emit_signal("battery::update")
				end
			end,
			stderr = function(out)
				local naughty = require("naughty")
				naughty.notify({
					title = "Oops! Error in sys.battery!",
					text = out,
					preset = naughty.config.presets.critical,
				})
			end,
		}
	)
end

battery:update()

return battery
