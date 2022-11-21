local e = extend("livingEntity")

e.model = dream:loadObject("objects/player", { callback = function(model)
	model:setVertexShader("bones")
end })

function e:new(position)
	e.super.new(self, position)
	
	self.cameraDistance = 5
	self.lookDirection = 0
	self.dialogueCameraBlend = 0
	
	self.torch = dream:newLight("point", vec3(1, 1, 1), vec3(1, 1, 0.2), 250)
	self.torch:addNewShadow()
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
	
	local mesh = e.model.objects.Armature.objects.Cube.meshes[1]
	mesh.material:setColor(1, 0, 0)
	mesh.material:setMetallic(1)
	mesh.material:setRoughness(0.5)
	e.model:getMainSkeleton():applyPose(pose)
	e.model:resetTransform()
	e.model:translate(self.position)
	e.model:rotateY(self.rot - math.pi / 2)
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
		local transform = e.model:getMainSkeleton():getTransform("mixamorig_RightHand")
		self.weaponTransform = (e.model.transform * transform):rotateY(-math.pi / 2):rotateX(-math.pi / 2)
		item:drawEquipped(self.weaponTransform)
	end
	
	e.super.draw(self)
end

function e:update(dt)
	if e.super.update(self, dt) then
		switchState("gameover")
	end
end

function e:control(dt)
	local d = love.keyboard.isDown
	local rot = 0
	
	local ax, az = 0, 0
	if d("w") then
		ax = 1
	end
	if d("d") then
		az = 1
	end
	if d("s") then
		ax = -1
	end
	if d("a") then
		az = -1
	end
	local a = math.sqrt(ax ^ 2 + az ^ 2)
	if a > 0 then
		ax = ax / a
		az = az / a
		
		local v = self.velocity
		local speed = vec3(v.x, 0, v.z):length()
		local maxSpeed = love.keyboard.isDown("lshift") and 6 or 3
		local dot = speed > 0 and (ax * v.x / speed + az * v.z / speed) or 0
		local accel = 1000 * math.max(0, 1 - speed / maxSpeed * math.abs(dot))
		accel = 3
		
		states.game:applyForce(self, ax * accel, az * accel)
	end
	
	--camera
	local tilt = 0.3
	local distance = 5
	local safetyMargin = 1
	local headPosition = self.position + vec3(0, 1, 0)
	local direction = vec3(-math.cos(rot) * tilt, 1, -math.sin(rot) * tilt):normalize()
	local cameraRay = direction * (distance + safetyMargin)
	
	--request collision check
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
	
	dream.camera:setTransform(
			dream:lookAt(headPosition + direction * distance, headPosition):invert()
	)
end

return e