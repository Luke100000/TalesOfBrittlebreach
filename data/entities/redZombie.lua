local e = extend("zombie")

e.model = dream:loadObject("objects/player", {callback = function(model)
	model:setVertexShader("bones")
end})
e.model:setShadowVisibility(false)

function e:new(position)
	e.super.new(self, position)
	
	self.walkingSpeed = 1.5
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
	
	e.model.meshes.Cube.material:setColor(1, 0, 1)
	e.model.meshes.Cube.material:setMetallic(1)
	e.model.meshes.Cube.material:setRoughness(1)
	e.model:applyPose(pose)
	e.model:resetTransform()
	e.model:scale(1 / 120)
	e.model:rotateY(self.rot - math.pi/2)
	e.model:translate(self.position)
	dream:draw(e.model)
end

return e