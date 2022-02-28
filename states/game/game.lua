states.game = { }

require("states/game/entities")
require("states/game/map")

world = dream:loadScene("objects/world")

cameraController = require("states/game/cameraController")

function states.game:switch()
	--setup physics world
	self.physicsWorld = physics:newWorld()
	self.worldCollider = self.physicsWorld:add(physics:newMesh(world))

	self.entities = { }
	
	self.player = self:newEntity("player", 3, 5, 0)
	
	self.freeFly = false
end

function states.game:draw()
	if self.freeFly then
		cameraController:setCamera(dream.cam)
	end
	
	dream:prepare()
	
	self:drawEntities()
	
	dream:draw(world)
	dream:present()
	
	if love.keyboard.isDown("m") then
		states.game:drawMap()
	end
end

function states.game:mousemoved(_, _, x, y)
	if self.freeFly then
		cameraController:mousemoved(x, y)
	end
end

function states.game:update(dt)
	dt = math.min(1 / 15, dt)
	
	if self.freeFly then
		cameraController:update(dt)
	else
		self.player:control(dt)
	end
	
	love.mouse.setRelativeMode(self.freeFly)
	
	self:updateEntities(dt)
	
	dream.delton:start("physics")
	self.physicsWorld:update(dt)
	dream.delton:stop()
end

function states.game:keypressed(key)
	if key == "f" then
		self.freeFly = not self.freeFly
	end
end