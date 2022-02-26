require("error")("Tales of Brittlebreach", "1.0.0")

states = { }
require("states/load/load")
require("states/game/game")

function switchState(s, ...)
	state = s
	states[state]:switch(...)
end
switchState("game")


local _, desktopHeight = love.window.getDesktopDimensions()
function love.draw()
	guiScale = 1 / math.sqrt(love.graphics.getHeight() / desktopHeight)
	
	if states[state].draw then
		states[state]:draw()
	end
	
	mousepressed_button = false
	mousereleased_button = false
	keypressed_button = false
	mousewheel_button = false
	buttonLocked = false
end

function love.update(dt)
	if states[state].update then
		states[state]:update(dt)
	end
	
	dream:update()
end

function love.keypressed(key, _, isRepeat)
	if not isRepeat then
		keypressed_button = key
	end

	if states[state].keypressed then
		states[state]:keypressed(key)
	end

	--screenshots!
	if key == "f2" then
		if love.keyboard.isDown("lctrl") then
			love.system.openURL(love.filesystem.getSaveDirectory() .. "/screenshots")
		else
			love.filesystem.createDirectory("screenshots")
			if not screenShotThread then
				screenShotThread = love.thread.newThread([[
					require("love.image")
					channel = love.thread.getChannel("screenshots")
					while true do
						local screenshot = channel:demand()
						screenshot:encode("png", "screenshots/screen_" .. tostring(os.time()) .. ".png")
					end
				]]):start()
			end
			love.graphics.captureScreenshot(love.thread.getChannel("screenshots"))
		end
	end

	--fullscreen
	if key == "f11" or (key == "return" and love.keyboard.isDown("lctrl", "rctrl")) then
		love.window.setFullscreen(not love.window.getFullscreen())
		love.resize(love.graphics.getWidth(), love.graphics.getHeight())
	end
end

function love.keyreleased(key)
	if states[state].keyreleased then
		states[state]:keyreleased(key)
	end
end

function love.mousepressed(x, y, b)
	if states[state].mousepressed then
		states[state]:mousepressed(x, y, b)
	end
	mousepressed_button = b
end

function love.mousereleased(x, y, b)
	if states[state].mousereleased then
		states[state]:mousereleased(x, y, b)
	end
	mousereleased_button = b
end

function love.wheelmoved(x, y)
	if states[state].wheelmoved then
		states[state]:wheelmoved(x, y)
	end
	mousewheel_button = y
end

function love.textinput(text)
	if states[state].textinput then
		states[state]:textinput(text)
	end
end

function love.resize(w, h)
	screen.w = w
	screen.h = h
	if states[state].resize then
		states[state]:resize(w, h)
	end
end

function love.quit(crashed)
	if states[state].quit then
		states[state]:quit()
	end
end