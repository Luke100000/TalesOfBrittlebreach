local e = extend("entity")

e.model = dream:loadObject("objects/player", {callback = function(model)
	model:setVertexShader("bones")
end})

e.anim = dream:loadObject("objects/animations/run")

function e:new(position)
	e.super.new(self, position)
	
	self.collider = states.game.physicsWorld:add(physics:newCircle(0.25, 1.75), "dynamic", position.x, position.y, position.z)
	self.rot = 0
	
	self.errorTime = 0
	self.pathFindCooldown = 0
end

function e:draw()
	local pose = (e.anim.animations.Default or e.anim.animations.Armature):getPose(love.timer.getTime())
	e.model.meshes.Cube.material:setColor(0, 1, 0)
	e.model.meshes.Cube.material:setMetallic(1)
	e.model.meshes.Cube.material:setRoughness(0.5)
	e.model:applyPose(pose)
	e.model:reset()
	e.model:scale(1 / 100)
	e.model:rotateY(self.rot - math.pi/2)
	e.model:translate(self.position)
	dream:draw(e.model)
	
	e.super.draw(self)
end

function e:update(dt)
	self.position = self.collider:getPosition()
	
	local cx, cy = self.collider:getVelocity()
	local squaredSpeed = cx^2 + cy^2
	if squaredSpeed > 1 then
		self.rot = math.atan2(cy, cx)
	end
	
	--request path
	if self.path ~= false then
		self.pathFindCooldown = self.pathFindCooldown - dt
		if self.pathFindCooldown < 0 then
			--states.game:requestPath(self.id, self.position.x, self.position.z, false, false, 256)
			states.game:requestPath(self.id, self.position.x, self.position.z, states.game.player.position.x, states.game.player.position.z)
			self.path = false
		end
	end
	
	if self.path == false then
		self.path = states.game:fetchRaytracerResult(self.id) or false
		self.errorTime = 0
		
		if self.path then
			self.pathFindCooldown = #self.path / 10
		end
	elseif self.path then
		if #self.path > 1 then
			local node = self.path[1]
			
			local delta = vec3(node[1], self.position.y, node[2]) - self.position
			if delta:lengthSquared() > 0.25 then
				local direction = delta:normalize() * 0.005
				self.collider:applyForce(direction.x, direction.z)
			else
				states.game:markPath(node[3], node[4], -1)
				table.remove(self.path, 1)
			end
			
			if self.collider.collided then
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
	
	return e.super.update(self, dt)
end

return e