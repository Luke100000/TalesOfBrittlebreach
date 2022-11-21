local e = extend("bullet")

e.model = dream:loadObject("objects/bullets/arrow")

function e:new(position, direction, shooter)
	e.super.new(self, position, direction, shooter)
	
	self.speed = 30
	self.damage = 5
end

function e:draw()
	e.model:resetTransform()
	e.model:translate(self.position)
	e.model:lookTowards(self.direction)
	dream:draw(e.model)
end

return e