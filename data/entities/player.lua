local e = extend("entity")

e.model = dream:loadObject("objects/player", {callback = function(model)
	model:setVertexShader("bones")
end})
e.model:print()

e.anim = dream:loadObject("objects/animations/run")
e.anim:print()

function e:new(position)
	e.super.new(self, position)
	
	self.collider = states.game.physicsWorld:add(physics:newCircle(0.25, 1.75), "dynamic", position.x, position.y, position.z)
	self.rot = 0
end

function e:draw()
	local pose = (e.anim.animations.Default or e.anim.animations.Armature):getPose(love.timer.getTime())
	e.model.meshes.Cube.material:setColor(1, 0, 0)
	e.model.meshes.Cube.material:setMetallic(1)
	e.model.meshes.Cube.material:setRoughness(0)
	e.model:applyPose(pose)
	e.model:reset()
	e.model:scale(1 / 100)
	e.model:rotateY(self.rot - math.pi/2)
	e.model:translate(self.position)
	dream:draw(e.model)
end

function e:update(dt)
	self.position = self.collider:getPosition()
end

function e:control(dt)
	local d = love.keyboard.isDown
	local speed = 0.01
	local rot = 0
	
	local cx, cy = self.collider:getVelocity()
	if cx^2 + cy^2 > 1 then
		self.rot = math.atan2(cy, cx)
	end
	
	if d("w") then
		self.collider:applyForce(
			math.cos(rot) * speed,
			math.sin(rot) * speed
		)
	end
	if d("d") then
		self.collider:applyForce(
			math.cos(rot+math.pi/2) * speed,
			math.sin(rot+math.pi/2) * speed
		)
	end
	if d("s") then
		self.collider:applyForce(
			math.cos(rot+math.pi) * speed,
			math.sin(rot+math.pi) * speed
		)
	end
	if d("a") then
		self.collider:applyForce(
			math.cos(rot-math.pi/2) * speed,
			math.sin(rot-math.pi/2) * speed
		)
	end
	
	local tilt = 0.3
	local distance = 6
	local direction = vec3(-math.cos(rot) * tilt, 1, -math.sin(rot) * tilt)
	direction = direction:normalize() * distance
	
	dream.cam:setTransform(
		dream:lookAt(self.position + direction, self.position):invert()
	)
end

return e