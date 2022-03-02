local e = extend("item")

e.model = dream:loadObject("objects/items/musket")

function e:new(position)
	e.super.new(self, position)
end

function e:use()

end

function e:drawEquipped()

end

function e:drawHotbar()

end

function e:drawItem()
	e.model:reset()
	e.model:scale(1 / 100)
	e.model:rotateY(self.rot - math.pi/2)
	e.model:translate(self.position)
	dream:draw(e.model)
	
	e.super.draw(self)
end

function e:update(dt)
	return e.super.update(self, dt)
end

return e