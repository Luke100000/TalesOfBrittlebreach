local e = extend("bullet")

e.model = dream:loadObject("objects/bullets/ball")

function e:new(position, direction, shooter)
	e.super.new(self, position, direction, shooter)
	
	self.speed = 30
	self.damage = 20
end

function e:draw()
	e.model:reset()
	e.model:translate(self.position)
	dream:draw(e.model)
end

return e