local aspawn = require("awful.spawn")
local gtimer = require("gears.timer")

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
	callbacks = { }
}

function wireless:enable()
	if self.enabled then return end
	self.enabled = true
	self:client_update()
end

function wireless:disable()
	if not self.enabled then return end
	self.enabled = false
	self:client_update()
end

function wireless:sync(cback)
	table.insert(self.callbacks, cback)
	cback(self)
end

function wireless:client_update()
	for _, cback in pairs(self.callbacks) do
		cback(self)
	end
end

function wireless:update()
	aspawn.easy_async("nmcli d wifi", function(out)
		local to_update = false
		local enabled = select(2, out:gsub("[^\r\n]+", "")) > 1
		if enabled ~= self.enabled then
			to_update = true
			self.enabled = enabled
		end
		if not self.enabled and not to_update then return end
		local bssid, ssid, signal
		for line in out:gmatch("[^\r\n]+") do
			if line:match("^%*") then
				local itr = line:gmatch("(.-)%s%s+")
				itr() -- throw '*'
				bssid, ssid = itr(), itr()
				_, _, _, signal = itr(), itr(), itr(), itr()
				break
			end
		end
		signal = tonumber(signal)
		self.signal = signal
		to_update = to_update or bssid ~= self.bssid or ssid ~= self.ssid
		if to_update then
			self.bssid, self.ssid = bssid, ssid
			self:client_update()
		end
	end)
end

gtimer({
	timeout = 10,
	call_now = false,
	autostart = true,
	callback = function()
		wireless:update()
	end
})

return wireless
