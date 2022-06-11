local e = extend("bullet")

e.model = dream:loadObject("objects/bullets/ball")

function e:new(position, direction, shooter, damage)
	e.super.new(self, position, direction, shooter)
	
	self.speed = 30
	self.damage = damage or 10
end

function e:draw()
	e.model:resetTransform()
	e.model:translate(self.position)
	dream:draw(e.model)
end

return e