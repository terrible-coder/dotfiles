local pulse = require("sys").pulse
local sound = pulse.object:implement(pulse.base)

local sink_all = require(... .. ".output")
local source_all = require(... .. ".input")

local sink = sink_all.object
local sink_widget = sink_all.widget
local source = source_all.object
local source_widget = source_all.widget

sound:ListenForSignal(pulse.base..".Device.VolumeUpdated", {
	sink.object_path, source.object_path,
})
sound:ListenForSignal(pulse.base..".Device.MuteUpdated", {
	sink.object_path, source.object_path,
})
-- sound:ListenForSignal("org.PulseAudio.Core1.Device.ActivePortUpdated", {
-- 	sink.object_path, source.object_path,
-- })
sound:ListenForSignal(pulse.base..".Device.StateUpdated", {
	source.object_path,
})
-- sound.ListenForSignal("org.PulseAudio.Core1.DevicePort.AvailableChanged", { })

return {
	sink = sink_widget,
	source = source_widget,
}
