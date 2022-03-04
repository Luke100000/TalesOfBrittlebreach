local e = { }

function e:new(position, direction, shooter)
	self.position = position
	self.direction = direction
	self.shooter = shooter
	
	self.initialPosition = self.position
	
	states.game:requestRaytrace(self.id, position, direction * 100)
	
	self.speed = 10
	self.damage = 5
end

function e:draw()
	
end

function e:update(dt)
	self.position = self.position + self.direction * dt * self.speed
	
	--hit wall
	self.hitPoint = self.hitPoint or states.game:fetchRaytracerResult(self.id)
	if self.hitPoint and self.hitPoint.pos then
		if (self.position - self.initialPosition):lengthSquared() > (self.initialPosition - self.hitPoint.pos):lengthSquared() then
			return true
		end
	end
	
	--hit enemy
	local entity = states.game:findNearestEntity(self.position, function(s) return s ~= self.shooter end)
	if entity then
		local distance = (self.position.x - entity.position.x)^2 + (self.position.z - entity.position.z)^2
		if distance < 0.5 then
			entity:damage(self.damage, self)
			return true
		end
	end
end

return e