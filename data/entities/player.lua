local e = extend("entity")

e.model = dream:loadObject("objects/player", {callback = function(model)
	model:setVertexShader("bones")
end})
e.model:print()

function e:new(position)
	e.super.new(self, position)
	
	self.collider = states.game.physicsWorld:add(physics:newCircle(0.25, 1.75), "dynamic", position.x, position.y, position.z)
	self.rot = 0
	
	self.cameraDistance = 5
end

function e:draw()
	local pose = data.animations.walkPlayer:getPose(love.timer.getTime())
	e.model.meshes.Cube.material:setColor(1, 0, 0)
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
	
	return e.super.update(self, dt)
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
	
	--camera
	local tilt = 0.3
	local distance = 5
	local safetyMargin = 1
	local headPosition = self.position + vec3(0, 1, 0)
	local direction = vec3(-math.cos(rot) * tilt, 1, -math.sin(rot) * tilt):normalize()
	local cameraRay = direction * (distance + safetyMargin)
	
	--request colliison check
	states.game:requestRaytrace("camera", headPosition, cameraRay)
	local pos = states.game.raytracerResults["camera"]
	if pos and pos.pos then
		distance = math.max(1, (pos.pos - headPosition):length() - safetyMargin)
	end
	
	--adapt distance
	if self.cameraDistance > distance + safetyMargin then
		self.cameraDistance = distance
	else
		self.cameraDistance = self.cameraDistance * (1 - dt) + distance * dt
	end
	
	--set camera
	dream.cam:setTransform(
		dream:lookAt(headPosition + direction * distance, headPosition):invert()
	)
end

return e