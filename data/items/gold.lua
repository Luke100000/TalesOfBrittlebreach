local e = extend("item")

e.model = dream:loadObject("objects/items/gold")

function e:new(position)
	e.super.new(self, position)
end

function e:use()

end

function e:draw()
	e.model:resetTransform()
	e.model:translate(self.position + vec3(0, math.cos(states.game.time) * 0.1, 0))
	e.model:rotateY(states.game.time)
	dream:draw(e.model)
	
	e.super.draw(self)
end

function e:update(dt)
	return e.super.update(self, dt)
end

function e:pickup()
	states.game.gold = states.game.gold + 1
	soundManager:play("ammo")
	
	if states.game.gold == 3 then
		states.game:newItem("shotgun", states.game.itemPositions.shotgun)
	end
end

return e