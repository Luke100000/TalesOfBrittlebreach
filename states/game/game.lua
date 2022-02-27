states.game = { }

require("states/game/entities")

love.mouse.setRelativeMode(true)

world = dream:loadScene("objects/world")

cameraController = require("states/game/cameraController")

function states.game:switch()
	self.entities = { }
	
	self.player = self:newEntity("player", 3, -1, 0)
end

function states.game:draw()
	cameraController:setCamera(dream.cam)
	
	dream:prepare()
	
	self:drawEntities()
	
	dream:draw(world)
	dream:present()
end

function love.mousemoved(_, _, x, y)
	cameraController:mousemoved(x, y)
end

function states.game:update(dt)
	cameraController:update(dt)
	
	self:updateEntities(dt)
end