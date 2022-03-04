states.game = { }

require("states/game/bullets")
require("states/game/entities")
require("states/game/items")
require("states/game/map")
require("states/game/raytracer")
require("states/game/pathFinder")
require("states/game/physics")

world = dream:loadScene("objects/world")
world:print()

states.game:loadRaytraceObject("objects/world")
states.game:loadPhysicsObject("objects/world")

cameraController = require("states/game/cameraController")

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
	
	self.player = self:newEntity("player", world.objects.spawn.transform * world.objects.spawn.positions[1].position)
	
	for d,s in pairs({"musket", "crossbow", "ammo"}) do
		for i,v in ipairs(world.objects[s].positions) do
			self:newItem(s, world.objects[s].transform * v.position)
		end
	end
	
	for _,pos in pairs(world.objects.spawner.positions) do
		local p = pos.position
		self:newEntity("zombie", p)
	end
	
	self.lights = { }
	for d,s in pairs(world.lights) do
		local s = s:clone()
		table.insert(self.lights, s)
		s:addShadow()
		s.shadow:setStatic(true)
		s.shadow:setSmooth(true)
		s:setAttenuation(3)
	end
	
	for i,v in pairs(world.objects) do
		for d,s in pairs(v.lights) do
			local s = s:clone()
			table.insert(self.lights, s)
			s:addShadow()
			s:setPosition(v.transform * s.pos)
			s.shadow:setStatic(true)
			s.shadow:setSmooth(true)
			s:setAttenuation(3)
		end
	end
	
	self.freeFly = false
	self.physicsUtilisation = 0
	
	self.dialogues = { }
	
	self.inventory = { }
	self.selected = 1
	self.ammo = 10
	
	self.time = 0
	
	--self:openDialogue(lang.story, vec3(10, 0, 20))
end

function states.game:openDialogue(text, positions)
	if type(text) == "string" then
		text = {text}
	end
	if positions and type(positions[1]) == "number" then
		positions = {positions}
	end
	local position
	for i = 1, #text do
		position = positions[i] or position
		table.insert(self.dialogues, {
			text = text[i],
			position = position,
		})
	end
end

function states.game:draw()
	if self.freeFly then
		cameraController:setCamera(dream.cam)
	end
	
	dream:prepare()
	
	local distance = 18
	table.sort(self.lights, function(a, b)
		a.dist = (a.pos - self.player.position):length()
		b.dist = (b.pos - self.player.position):length()
		return a.dist < b.dist
	end)
	for d,s in ipairs(self.lights) do
		if s.dist < distance then
			s.originalBrightness = s.originalBrightness or s.brightness
			s.brightness = s.originalBrightness * math.min(1, distance - s.dist)
			dream:addLight(s)
		else
			break
		end
	end
	
	self:drawBullets()
	self:drawEntities()
	self:drawItems()
	
	dream:draw(world)
	dream:present()
	
	if love.keyboard.isDown("m") then
		states.game:drawMap()
	end
	
	--crosshair
	local x, y = love.mouse.getPosition()
	local s = 10
	local c = 4
	love.graphics.line(x - s, y, x + s, y)
	love.graphics.line(x, y - s, x, y + s)
	love.graphics.line(x - s, y - c, x - s, y + c)
	love.graphics.line(x + s, y - c, x + s, y + c)
	love.graphics.line(x - c, y - s, x + c, y - s)
	love.graphics.line(x - c, y + s, x + c, y + s)
	
	local w = 700
	local h = 500
	local scale = math.min(screen.w / w, screen.h / h)
	love.graphics.push()
	love.graphics.translate((screen.w - w * scale) / 2, (screen.h - h * scale) / 2)
	love.graphics.scale(scale)
	
	--dialogue
	if #self.dialogues > 0 then
		love.graphics.push()
		love.graphics.translate(175, 175)
		love.graphics.setColor(0, 0, 0, 0.5)
		love.graphics.rectangle("fill", 0, 0, 350, 150, 16)
		love.graphics.setColor(1, 1, 1)
		love.graphics.printf(self.dialogues[1].text, 10, 20, 330 / 0.5, "center", 0, 0.5)
		love.graphics.setColor(1, 1, 1, 0.5)
		love.graphics.printf("(press space to continue)", 10, 120, 330 / 0.5, "center", 0, 0.5)
		love.graphics.pop()
	end
	
	--pickup items
	for d,s in ipairs(self.items) do
		if (s.position - self.player.position):lengthSquared() < 10 then
			love.graphics.push()
			love.graphics.translate(260, 400)
			love.graphics.setColor(0, 0, 0, 0.5)
			love.graphics.rectangle("fill", 0, 0, 200, 30, 16)
			love.graphics.setColor(1, 1, 1)
			love.graphics.printf("press E to pick up", 0, 6, 200 / 0.5, "center", 0, 0.5)
			love.graphics.pop()
			
			if keypressed_button == "e" then
				table.remove(self.items, d)
				s:pickup()
			end
			break
		end
	end
	
	--ammo
	if self.inventory[self.selected] and self.inventory[self.selected].ammo then
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(self.ammo .. " ammo", 5, h - 40, 0, 0.5)
	end
	
	--items
	for d,s in ipairs(self.inventory) do
		love.graphics.push()
		love.graphics.translate(w - 100, h - 40 * (#self.inventory - d + 1))
		love.graphics.setColor(0, 0, 0, 0.5)
		love.graphics.rectangle("fill", 0, 0, 100, 30, 5)
		if states.game.selected == d then
			love.graphics.setColor(1, 1, 1, 0.5)
			love.graphics.setLineWidth(2)
			love.graphics.rectangle("line", 0, 0, 100, 30, 5)
		end
		love.graphics.setColor(1, 1, 1)
		love.graphics.printf(s.name, 0, 6, 90 / 0.5, "center", 0, 0.5)
		love.graphics.setColor(1, 1, 1, 0.5)
		love.graphics.printf(d, 0, 6, 100 / 0.5 - 10, "right", 0, 0.5)
		love.graphics.pop()
	end
	
	love.graphics.pop()
	
	
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
	
	if love.keyboard.isDown("f1") then
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(love.timer.getFPS() .. " FPS\nPhysics utilisation: " .. math.ceil(self.physicsUtilisation * 100) .. "%", 5, 5, 0, 0.5)
	end
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
	
	self.time = self.time + dt
	
	love.mouse.setRelativeMode(self.freeFly)
	love.mouse.setVisible(self.freeFly)
	
	if #self.dialogues == 0 then
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
end

function states.game:getShootingDirection(entity)
	local x, y = love.mouse.getPosition()
	local direction = vec3(
		screen.h / 2 - y,
		0,
		x - screen.w / 2
	)
	direction = direction:normalize()
	
	local e = states.game:findNearestEntity(entity.position, function(s) return s ~= entity end)
	if e then
		local diff = e.position - entity.position
		direction[2] = diff.y / math.sqrt(diff.x^2 + diff.y^2)
	end
	return direction
end

function states.game:mousepressed(x, y, b)
	if b == 1 and self.inventory[self.selected] then
		self.inventory[self.selected]:use(self.player)
	end
end

function states.game:keypressed(key)
	if tonumber(key) then
		states.game.selected = tonumber(key)
	end
	
	if key == "f" then
		self.freeFly = not self.freeFly
	end
	
	if key == "m" then
		self:requestPathfinderDebug()
	end
	
	if key == "space" then
		table.remove(self.dialogues, 1)
	end
end