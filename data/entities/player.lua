local e = extend("livingEntity")

e.model = dream:loadObject("objects/player", {callback = function(model)
	model:setVertexShader("bones")
end})

function e:new(position)
	e.super.new(self, position)
	
	self.cameraDistance = 5
	self.lookDirection = 0
	self.dialogueCameraBlend = 0
	
	self.torch = dream:newLight("point", vec3(1, 1, 1), vec3(1, 1, 0.2), 25)
	self.torch:addShadow()
	self.torch.shadow:setSmooth(true)
	self.torch.shadow:setStatic(true)
	self.torch:setAttenuation(3)
end

function e:draw()
	local pose
	
	if self.speed > 0.1 then
		pose = data.animations.walkPlayer:getPose(self.walkingAnimation)
	else
		pose = data.animations.standPlayer:getPose(states.game.time)
	end
	
	self.rot = self.lookDirection
	
	e.model.meshes.Cube.material:setColor(1, 0, 0)
	e.model.meshes.Cube.material:setMetallic(1)
	e.model.meshes.Cube.material:setRoughness(0.5)
	e.model:applyPose(pose)
	e.model:reset()
	e.model:scale(1 / 100)
	e.model:rotateY(self.rot - math.pi/2)
	e.model:translate(self.position)
	dream:draw(e.model)
	
	local dist = 0
	self.torch:setPosition(self.position + vec3(
		math.cos(self.rot) * dist,
		1.5,
		math.sin(self.rot) * dist
	))
	dream:addLight(self.torch)
	
	local item = states.game.inventory[states.game.selected]
	if item then
		local transform = e.model.skeleton:getTransform("mixamorig_RightHand")
		self.weaponTransform = e.model.transform * transform * mat4:getScale(100) * mat4:getRotateY(math.pi/2) * mat4:getRotateX(-math.pi/2)
		item:drawEquipped(self.weaponTransform)
	end
	
	e.super.draw(self)
end

function e:update(dt)
	return e.super.update(self, dt)
end

function e:control(dt)
	local d = love.keyboard.isDown
	local speed = 0.01
	local rot = 0
	
	local cx, cy = 0, 0
	if d("w") then
		cx = 1
	end
	if d("d") then
		cy = 1
	end
	if d("s") then
		cx = -1
	end
	if d("a") then
		cy = -1
	end
	local v = math.sqrt(cx^2 + cy^2)
	if v > 0 then
		states.game:applyForce(self,
			cx * speed / v,
			cy * speed / v
		)
	end
	
	--camera
	local tilt = 0.3
	local distance = 5
	local safetyMargin = 1
	local headPosition = self.position + vec3(0, 1, 0)
	local direction = vec3(-math.cos(rot) * tilt, 1, -math.sin(rot) * tilt):normalize()
	local cameraRay = direction * (distance + safetyMargin)
	
	--request collison check
	--states.game:requestRaytrace("camera", headPosition, cameraRay)
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
	if states.game.dialogues[1] and states.game.dialogues[1].position then
		headPosition = states.game.dialogues[1].position * self.dialogueCameraBlend + headPosition * (1 - self.dialogueCameraBlend)
		self.dialogueCameraBlend = math.min(1, self.dialogueCameraBlend + dt * 3)
	else
		self.dialogueCameraBlend = math.max(0, self.dialogueCameraBlend - dt * 3)
	end
	
	dream.cam:setTransform(
		dream:lookAt(headPosition + direction * distance, headPosition):invert()
	)
end

return e