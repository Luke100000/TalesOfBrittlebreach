local e = extend("entity")

e.model = dream:loadObject("objects/player", {callback = function(model)
	model:setVertexShader("bones")
end})

e.anim = dream:loadObject("objects/animations/run")

function e:new(position)
	e.super.new(self, position)
	
	self.collider = states.game.physicsWorld:add(physics:newCircle(0.25, 1.75), "dynamic", position.x, position.y, position.z)
	self.rot = 0
end

function e:draw()
	local pose = (e.anim.animations.Default or e.anim.animations.Armature):getPose(love.timer.getTime())
	e.model.meshes.Cube.material:setColor(0, 1, 0)
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
	
	local cx, cy = self.collider:getVelocity()
	if cx^2 + cy^2 > 1 then
		self.rot = math.atan2(cy, cx)
	end
	
	local delta = states.game.player.position - self.position
	if delta:lengthSquared() > 2.0 then
		local direction = delta:normalize() * 0.01
	self.collider:applyForce(direction.x, direction.z)
	end
end

return e