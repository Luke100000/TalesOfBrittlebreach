local e = extend("bullet")

e.model = dream:loadObject("objects/bullets/arrow")

function e:new(position, direction, shooter)
	e.super.new(self, position, direction, shooter)
	
	self.speed = 30
	self.damage = 10
end

function e:draw()
	e.model:setDirection(self.direction)
	e.model:translate(self.position)
	dream:draw(e.model)
end

return e