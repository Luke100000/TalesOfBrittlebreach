local e = extend("entity")

function e:new(position)
	e.super.new(self, position)
	
	states.game:addDynamics(self, 0.2, 1.5)
	
	self.rot = 0
	self.speed = 0
	self.walkingAnimation = 0
	
	self.velocity = vec3()
end

function e:update(dt)
	self.speed = math.sqrt(self.velocity.x^2 + self.velocity.z^2)
	if self.speed > 1 then
		self.rot = math.atan2(self.velocity.z, self.velocity.x)
	end
	
	self.walkingAnimation = self.walkingAnimation + dt * self.speed * 0.5
	
	return e.super.update(self, dt)
end

return e