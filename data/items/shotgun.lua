local e = extend("item")

e.model = dream:loadObject("objects/items/shotgun")

e.ammo = true

function e:new(position)
	e.super.new(self, position)
end

function e:use(entity)
	if not self.lastUse or (states.game.time - self.lastUse) > 0.5 then
		self.lastUse = states.game.time
		if states.game.ammo > 0 then
			local direction = states.game:getShootingDirection(entity)
			for i = 1, 8 do
				states.game:newBullet("ball", entity.weaponTransform * vec3(0.8, 0, 0), direction:normalize() + vec3(
					math.random()-0.5,
					math.random()-0.5,
					math.random()-0.5
				) * 0.35, entity, 5)
			end
			states.game.ammo = states.game.ammo - 1
			soundManager:play("musket")
		end
	end
end

function e:drawEquipped(t)
	e.model:setTransform(t)
	dream:draw(e.model)
	
	e.super.draw(self)
end

function e:draw()
	e.model:reset()
	e.model:translate(self.position + vec3(0, math.cos(states.game.time) * 0.1, 0))
	e.model:rotateY(states.game.time)
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