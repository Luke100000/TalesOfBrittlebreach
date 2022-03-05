states.gameover = { }

local big = love.graphics.newFont("fonts/Kingthings Calligraphica.ttf", 48)
local small = love.graphics.newFont("fonts/Kingthings Calligraphica.ttf", 32)

function states.gameover:switch()
end

function states.gameover:draw()
	local y = love.graphics.getHeight() / 2
	
	love.graphics.clear(0.4, 0.1, 0.1)
	
	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(big)
	love.graphics.printf("Tales of Brittlebreach", 0, y - 110, love.graphics.getWidth(), "center")
	
	love.graphics.setFont(small)
	love.graphics.printf("You died.", 0, y - 30, love.graphics.getWidth(), "center")
	
	love.graphics.setColor(1, 1, 1, 0.75 + math.cos(love.timer.getTime()) * 0.25)
	love.graphics.printf("Press escape to exit!", 0, y + 60, love.graphics.getWidth(), "center")
end

function states.gameover:keypressed(key)
	if key == "escape" then
		os.exit()
	end
end