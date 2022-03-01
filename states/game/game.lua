states.game = { }

require("states/game/bullets")
require("states/game/entities")
require("states/game/map")
require("states/game/raytracer")
require("states/game/pathFinder")

world = dream:loadScene("objects/world")
states.game:loadRaytraceObject("objects/world")

cameraController = require("states/game/cameraController")

sun = dream:newLight("sun", vec3(1, 1, 1), vec3(1, 1, 1), 1)
sun:addShadow()

dream:setSky(love.graphics.newImage("textures/hdri.jpg"))

function states.game:switch()
	--setup physics world
	self.physicsWorld = physics:newWorld()
	self.worldCollider = self.physicsWorld:add(physics:newMesh(world))

	self.bullets = { }
	self.entities = { }
	
	self.player = self:newEntity("player", vec3(3, 5, 0))
	
	self:newEntity("zombie", vec3(10, 5, 0))
	
	self.freeFly = false
end

function states.game:draw()
	if self.freeFly then
		cameraController:setCamera(dream.cam)
	end
	
	dream:prepare()
	
	dream:addLight(sun)
	
	self:drawBullets()
	self:drawEntities()
	
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
	
	local path = self.entities[2].path
	if path then
		local positions = { }
		for d,s in ipairs(path) do
			local pixel = dream.cam.transformProj * vec3(s[1], 0, s[2])
			pixel = (pixel / pixel.z + 1.0) / 2 * vec3(screen.w, screen.h, self.player.position.y)
			table.insert(positions, pixel.x)
			table.insert(positions, pixel.y)
		end
		if #positions > 2 then
			love.graphics.setLineWidth(2)
			love.graphics.line(positions)
		end
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
	
	self:updateBullets(dt)
	self:updateEntities(dt)
	self:updateRaytracer()
	self:updatePathfinder()
	
	dream.delton:start("physics")
	self.physicsWorld:update(dt)
	dream.delton:stop()
end

function states.game:mousepressed(x, y, b)
	local nx = x / screen.w * 2 - 1
	local ny = y / screen.h * 2 - 1
	local direction = dream:pixelToPoint(vec3(x, y, 1000)) - dream.cam.pos
	
	self:requestRaytrace(
		function(task)
			if task.pos then
				self:newBullet("musket", self.player.position, (task.pos - self.player.position):normalize())
			end
		end,
		dream.cam.pos, direction)
end

function states.game:keypressed(key)
	if key == "f" then
		self.freeFly = not self.freeFly
	end
	
	if key == "m" then
		self:requestPathfinderDebug()
	end
end