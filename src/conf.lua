function love.conf(t)
	local version = "0.3.1"

	t.identity = nil
	t.version = "11.1"
	t.console = false
	t.accelerometerjoystick = false
	t.externalstorage = false
	t.gammacorrect = false

	t.window.title = "snekLOVE v" .. version .. " by Bytewave"
end