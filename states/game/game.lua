states.game = { }

require("states/game/bullets")
require("states/game/entities")
require("states/game/items")
require("states/game/map")
require("states/game/raytracer")
require("states/game/pathFinder")
require("states/game/physics")

world = dream:loadScene("objects/world")
states.game:loadRaytraceObject("objects/world")
states.game:loadPhysicsObject("objects/world")

cameraController = require("states/game/cameraController")

sun = dream:newLight("sun", vec3(1, 1, 1), vec3(1, 1, 1), 0)
sun:addShadow()

dream:setSky(love.graphics.newImage("textures/hdri.jpg"), 0.1)

local lastId = 0
function states.game:getId()
	lastId = lastId + 1
	return lastId
end

function states.game:switch()
	self.bullets = { }
	self.entities = { }
	self.items = { }
	
	self.player = self:newEntity("player", vec3(3, 5, 0))
	
	self:newEntity("zombie", vec3(8, 5, 0))
	
	self.freeFly = false
	self.physicsUtilisation = 0
end

function states.game:draw()
	if self.freeFly then
		cameraController:setCamera(dream.cam)
	end
	
	dream:prepare()
	
	--dream:addLight(sun)
	
	self:drawBullets()
	self:drawEntities()
	self:drawItems()
	
	dream:draw(world)
	dream:present()
	
	if love.keyboard.isDown("m") then
		states.game:drawMap()
	end
	
	local x, y = love.mouse.getPosition()
	local s = 10
	local c = 4
	love.graphics.line(x - s, y, x + s, y)
	love.graphics.line(x, y - s, x, y + s)
	love.graphics.line(x - s, y - c, x - s, y + c)
	love.graphics.line(x + s, y - c, x + s, y + c)
	love.graphics.line(x - c, y - s, x + c, y - s)
	love.graphics.line(x - c, y + s, x + c, y + s)
	
--	local path = self.entities[2].path
--	if path then
--		local positions = { }
--		for d,s in ipairs(path) do
--			local pixel = dream.cam.transformProj * vec3(s[1], 0, s[2])
--			pixel = (pixel / pixel.z + 1.0) / 2 * vec3(screen.w, screen.h, self.player.position.y)
--			table.insert(positions, pixel.x)
--			table.insert(positions, pixel.y)
--		end
--		if #positions > 2 then
--			love.graphics.setLineWidth(2)
--			love.graphics.line(positions)
--		end
--	end

	love.graphics.print(love.timer.getFPS() .. " FPS\nPhysics utilisation: " .. math.ceil(self.physicsUtilisation * 100) .. "%", 5, 5)
end

function states.game:mousemoved(_, _, x, y)
	if self.freeFly then
		cameraController:mousemoved(x, y)
	end
end

function states.game:update(dt)
	dt = math.min(1 / 15, dt)
	
	if love.keyboard.isDown("b") then
		dt = dt * 0.1
	end
	
	if self.freeFly then
		cameraController:update(dt)
	else
		self.player:control(dt)
	end
	
	love.mouse.setRelativeMode(self.freeFly)
	
	self:updateBullets(dt)
	self:updateEntities(dt)
	self:updateItems(dt)
	self:updateRaytracer()
	self:updatePathfinder()
	self:updatePhysics(dt)
	
	if #self.entities < 10 then
		if math.random() < dt * 0.25 then
			self:newEntity("zombie", vec3(8, 5, 0))
		end
	end
	
	local x, y = love.mouse.getPosition()
	local entity = states.game:findNearestEntity(self.player.position, function(s) return s ~= self.player end)
	local direction = vec3(
		screen.h / 2 - y,
		0,
		x - screen.w / 2
	)
	self.player.lookDirection = math.atan2(direction.z, direction.x)
end

function states.game:mousepressed(x, y, b)
	local entity = states.game:findNearestEntity(self.player.position, function(s) return s ~= self.player end)
	local direction = vec3(
		screen.h / 2 - y,
		0,
		x - screen.w / 2
	)
	direction = direction:normalize()
	
	if entity then
		local diff = entity.position - self.player.position
		direction[2] = diff.y / math.sqrt(diff.x^2 + diff.y^2)
	end
	self:newBullet("musket", self.player.position + vec3(0, 0.8, 0), direction:normalize(), self.player)
end

function states.game:keypressed(key)
	if key == "f" then
		self.freeFly = not self.freeFly
	end
	
	if key == "m" then
		self:requestPathfinderDebug()
	end
end