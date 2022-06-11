local e = extend("item")

e.model = dream:loadObject("objects/items/ammo")

function e:new(position)
	e.super.new(self, position)
end

function e:use()

end

function e:draw()
	e.model:resetTransform()
	e.model:rotateY(states.game.time)
	e.model:translate(self.position + vec3(0, math.cos(states.game.time) * 0.1, 0))
	dream:draw(e.model)
	
	e.super.draw(self)
end

function e:update(dt)
	return e.super.update(self, dt)
end

function e:pickup()
	states.game.ammo = states.game.ammo + 5
	soundManager:play("ammo")
end

return e