local e = extend("entity")

model = dream:loadObject("objects/player", {callback = function(model)
	model:setVertexShader("bones")
end})
model:print()

anim = model

function e:new(x, y, z)
	self.super:new(x, y, z)
	
	self.collider =  states.game.physicsWorld:add(physics:newCircle(0.25, 1.75), "dynamic", x, y, z)
	self.rot = 0
end

function e:draw()
	local pose = anim.animations.Armature:getPose(love.timer.getTime())
	model:applyPose(pose)
	model:reset()
	model:scale(1 / 100)
	model:rotateY(self.rot - math.pi/2)
	model:translate(self.x, self.y, self.z)
	dream:draw(model)
end

function e:update(dt)
	self.x, self.y, self.z = self.collider:getPosition()
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
		dream:lookAt(
			vec3(self.x, self.y, self.z) + direction,
			vec3(self.x, self.y, self.z)
		):invert()
	)
end

return e