local e = { }

function e:new(position)
	self.position = position
	self.health = 20
end

function e:draw()

end

function e:update(dt)
	return self.health <= 0
end

function e:control(dt)
	
end

function e:damage(damage, attacker)
	self.health = self.health - damage
end

return e