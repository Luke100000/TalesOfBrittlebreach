local e = extend("bullet")

e.model = dream:loadObject("objects/musket")

function e:new(position, direction, shooter)
	e.super.new(self, position, direction, shooter)
	
	self.initialPosition = self.position
	
	states.game:requestRaytrace(self.id, position, direction * 100)
end

function e:draw()
	e.model:reset()
	e.model:translate(self.position)
	dream:draw(e.model)
end

function e:update(dt)
	self.position = self.position + self.direction * dt * 30
	
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
		if distance < 1 then
			entity:damage(10, self)
			return true
		end
	end
end

return e