local e = extend("item")

e.model = dream:loadObject("objects/items/crossbow")

function e:new(position)
	e.super.new(self, position)
end

function e:use(entity)
	if not self.lastUse or (states.game.time - self.lastUse) > 0.5 then
		self.lastUse = states.game.time
		local direction = states.game:getShootingDirection(entity)
		states.game:newBullet("arrow", entity.weaponTransform * vec3(0.8, 0, 0), direction:normalize(), entity)
		soundManager:play("crossbow")
	end
end

function e:drawEquipped(t)
	e.model:setTransform(t)
	dream:draw(e.model)
	
	e.super.draw(self)
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
	soundManager:play("pickup")
	table.insert(states.game.inventory, self)
end

return e