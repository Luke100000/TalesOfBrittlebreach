states.menu = { }

local big = love.graphics.newFont("fonts/Kingthings Calligraphica.ttf", 48)
local small = love.graphics.newFont("fonts/Kingthings Calligraphica.ttf", 32)

function states.menu:switch()
end

function states.menu:draw()
	local y = love.graphics.getHeight() / 2
	
	love.graphics.clear(0.4, 0.1, 0.1)
	
	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(big)
	love.graphics.printf("Tales of Brittlebreach", 0, y - 110, love.graphics.getWidth(), "center")
	
	love.graphics.setFont(small)
	love.graphics.printf("A prototype using 3DreamEngine\nEverything is pure Lua/LÖVE", 0, y - 30, love.graphics.getWidth(), "center")
	
	love.graphics.setColor(1, 1, 1, 0.75 + math.cos(love.timer.getTime()) * 0.25)
	love.graphics.printf("Press any key to start!", 0, y + 60, love.graphics.getWidth(), "center")
end

function states.menu:keypressed(key)
	switchState("game")
end