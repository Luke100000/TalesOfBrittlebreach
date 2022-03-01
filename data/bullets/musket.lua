local e = extend("bullet")

e.model = dream:loadObject("objects/musket")

function e:new(position, direction)
	e.super.new(self, position, direction)
	
	self.initialPosition = self.position
	
	states.game:requestRaytrace("bullet", position, direction * 100)
end

function e:draw()
	e.model:reset()
	e.model:translate(self.position)
	dream:draw(e.model)
end

function e:update(dt)
	self.position = self.position + self.direction * dt * 30
	
	self.hitPoint = self.hitPoint or states.game:fetchRaytracerResult("bullet")
	if self.hitPoint and self.hitPoint.pos then
		return (self.position - self.initialPosition):lengthSquared() > (self.initialPosition - self.hitPoint.pos):lengthSquared()
	end
end

return e