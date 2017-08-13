function love.conf(t)
	local version = "0.2.2"

	t.identity = nil
	t.version = "0.10.2"
	t.console = false
	t.accelerometerjoystick = false
	t.externalstorage = false
	t.gammacorrect = false

	t.window.title = "snekLOVE v" .. version .. " by Bytewave"
end