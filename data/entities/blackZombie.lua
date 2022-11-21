local e = extend("zombie")

e.model = dream:loadObject("objects/player", {callback = function(model)
	model:setVertexShader("bones")
end})
e.model:setShadowVisibility(false)

function e:new(position)
	e.super.new(self, position)
	
	self.walkingSpeed = 0.5
	self.health = 50
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
	
	local mesh = e.model.objects.Armature.objects.Cube.meshes[1]
	mesh.material:setColor(0.0, 0.0, 0.0)
	mesh.material:setMetallic(0)
	mesh.material:setRoughness(0.5)
	e.model:getMainSkeleton():applyPose(pose)
	e.model:translate(self.position)
	e.model:resetTransform()
	e.model:scale(1 / 75)
	e.model:rotateY(self.rot - math.pi/2)
	dream:draw(e.model)
end

return e