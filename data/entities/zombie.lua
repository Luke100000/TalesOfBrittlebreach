local e = extend("livingEntity")

e.model = dream:loadObject("objects/player", {callback = function(model)
	model:setVertexShader("bones")
end})
e.model:setShadowVisibility(false)

function e:new(position)
	e.super.new(self, position)
	
	self.errorTime = 0
	self.pathFindCooldown = 0
	
	self.attackTimer = 0
	self.dieTimer = 0
	
	self.state = math.random() < 0.2 and "attack" or math.random() < 0.8 and "idle" or "sleeping"
end

function e:draw()
	local pose
	if self.health <= 0 then
		pose = data.animations.dieZombie:getPose(math.min(12 / 30, self.dieTimer))
	elseif self.attackTimer > 0 then
		pose = data.animations.attackZombie:getPose((1 - self.attackTimer) * 1.5)
	elseif self.speed > 0.1 then
		pose = data.animations.walkZombie:getPose(self.walkingAnimation)
	else
		pose = data.animations.standZombie:getPose(self.walkingAnimation)
	end
	
	e.model.meshes.Cube.material:setColor(0, 1, 0)
	e.model.meshes.Cube.material:setMetallic(1)
	e.model.meshes.Cube.material:setRoughness(0.5)
	e.model:applyPose(pose)
	e.model:resetTransform()
	e.model:scale(1 / 100)
	e.model:rotateY(self.rot - math.pi/2)
	e.model:translate(self.position)
	dream:draw(e.model)
	
	e.super.draw(self)
end

function e:update(dt)
	--request path
	if self.path ~= false and self.state ~= "sleeping" then
		self.pathFindCooldown = self.pathFindCooldown - dt
		if self.pathFindCooldown < 0 then
			if self.state == "idle" then
				states.game:requestPath(self.id, self.position.x, self.position.z, false, false, 256)
			elseif self.state == "attack" then
				states.game:requestPath(self.id, self.position.x, self.position.z, states.game.player.position.x, states.game.player.position.z)
			end
			self.path = false
		end
	end
	
	if self.health <= 0 then
		self.dieTimer = self.dieTimer + dt
		if self.state ~= "dead" then
			self.state = "dead"
			self:onDeath()
		end
	end
	
	local dist = (self.position - states.game.player.position):lengthSquared()
	
	if self.state == "sleeping" and dist < 8^2 then
		self.state = "idle"
	end
	
	if self.state == "idle" and dist < 16^2 then
		self.state = "attack"
	end
	
	--attack
	self.attackTimer = self.attackTimer - dt
	if self.state == "attack" and dist < 1 and self.attackTimer < 0 then
		self.state = "idle"
		soundManager:play("punch")
		states.game.player:damage(1, self)
		self.attackTimer = 1
	end
	
	if self.state ~= "dead" then
		if self.path == false then
			self.path = states.game:fetchRaytracerResult(self.id) or false
			self.errorTime = 0
			
			if self.path then
				if self.state == "idle" then
					self.pathFindCooldown = #self.path / 4 + math.random() * 10
				else
					self.pathFindCooldown = #self.path / 10
				end
			end
		elseif self.path then
			if #self.path > 1 then
				local node = self.path[1]
				
				local delta = vec3(node[1], self.position.y, node[2]) - self.position
				if delta:lengthSquared() > 0.25 and dist > 0.75 then
					local direction = delta:normalize() * (self.state == "idle" and 0.0025 or 0.005) * (self.walkingSpeed or 1)
					states.game:applyForce(self, direction.x, direction.z)
				else
					--states.game:markPath(node[3], node[4], -1)
					table.remove(self.path, 1)
				end
				
				if self.collided then
					self.errorTime = self.errorTime + dt
					if self.errorTime > 0.1 then
						states.game:markPath(node[3], node[4], 1)
						self.path = nil
						self.errorTime = 0
					end
				else
					self.errorTime = 0
				end
			else
				self.path = nil
			end
		end
	end
	
	return e.super.update(self, dt)
end

function e:onDeath()
	soundManager:play("death" .. math.random(1, 5))
end

function e:damage(dmg)
	if self.state ~= "dead" then
		self.state = "attack"
	end
	return e.super.damage(self, dmg)
end

return e