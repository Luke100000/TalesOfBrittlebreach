local e = extend("entity")

function e:new(position)
	e.super.new(self, position)
	
	self.collider = states.game.physicsWorld:add(physics:newCircle(0.25, 1.75), "dynamic", position.x, position.y, position.z)
	
	self.rot = 0
	self.speed = 0
	self.walkingAnimation = 0
end

function e:update(dt)
	self.position = self.collider:getPosition()
	
	local cx, cy = self.collider:getVelocity()
	self.speed = math.sqrt(cx^2 + cy^2)
	if self.speed > 1 then
		self.rot = math.atan2(cy, cx)
	end
	
	self.walkingAnimation = self.walkingAnimation + dt * self.speed
	
	return e.super.update(self, dt)
end

return e