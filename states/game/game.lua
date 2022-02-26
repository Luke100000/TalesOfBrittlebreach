states.game = { }

model = dream:loadObject("objects/Running")
world = dream:loadScene("objects/world")

cameraController = require("states/game/cameraController")

local player = {
	ax = 0,
	ay = 0,
	az = 0,
	x = 0,
	y = 0,
	z = 0,
	rx = 0,
	ry = 0,
}

function states.game:switch()
	
end

function states.game:draw()
	cameraController:setCamera(dream.cam)
	
	dream:prepare()
	dream:draw(model)
	dream:draw(world)
	dream:present()
end

function love.mousemoved(_, _, x, y)
	cameraController:mousemoved(x, y)
end

function states.game:update(dt)
	cameraController:update(dt)
end