local aspawn = require("awful.spawn")
local gobject = require("gears.object")
local config_dir = require("gears.filesystem").get_configuration_dir()

local wireless = {
	device = "wlp3s0",
	enabled = true,
	bssid = "",
	ssid = "",
	signal = 0,
	speed = {
		last_rx = 0, last_tx = 0,
		up = 0, down = 0,
	},
}

wireless = gobject({ class = wireless })

function wireless:enable()
	if self.enabled then return end
	self.enabled = true
	self:emit_signal("network::update")
end

function wireless:disable()
	if not self.enabled then return end
	self.enabled = false
	self:emit_signal("network::update")
end

function wireless:update()
	aspawn.with_line_callback(
		"sh "..config_dir.."scripts/poll-wifi.sh",
		{
			stdout = function(out)
				if out == "Disabled" then
					if self.enabled then
						self.enabled = false
						self:emit_signal("network::update")
					end
					return
				end
				local fields = out:gmatch("[^,]+")
				local bssid = fields()
				local ssid = fields()
				local signal = tonumber(fields())
				local to_update = not self.enabled
				self.enabled = true
				to_update = to_update or bssid ~= self.bssid or ssid ~= self.ssid
				if to_update then
					self.bssid, self.ssid = bssid, ssid
					self.signal = signal
					self:emit_signal("network::update")
				end
			end,
			stderr = function(err)
				local naughty = require("naughty")
				naughty.notify({
					title = "Oops! Error in sys.network!",
					text = err,
					preset = naughty.config.presets.critical,
				})
			end,
		}
	)
end

wireless:update()

return wireless
