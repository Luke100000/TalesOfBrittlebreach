local e = extend("item")

e.model = dream:loadObject("objects/items/ammo")

function e:new(position)
	e.super.new(self, position)
end

function e:use()

end

function e:draw()
	e.model:reset()
	e.model:rotateY(love.timer.getTime())
	e.model:translate(self.position + vec3(0, math.cos(love.timer.getTime()) * 0.1, 0))
	dream:draw(e.model)
	
	e.super.draw(self)
end

function e:update(dt)
	return e.super.update(self, dt)
end

function e:pickup()
	states.game.ammo = states.game.ammo + 10
	soundManager:play("ammo")
end

return e