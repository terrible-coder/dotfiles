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
	self.callbacks = table.insert(self.callbacks, cback)
	cback(self)
end

function wireless:client_update()
	for _, cback in pairs(self.callbacks) do
		cback(self)
	end
end

function wireless:update()
	aspawn.easy_async("nmcli d wifi", function(out)
		local enabled = select(2, out:gsub("[^\r\n]+", "")) > 1
		if not enabled and self.enabled then
			self.enabled = enabled
			self:client_update()
			return
		end
		if not self.enabled then return end
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
		if bssid ~= self.bssid or ssid ~= self.ssid or signal ~= self.signal then
			self.bssid, self.ssid, self.signal = bssid, ssid, signal
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
