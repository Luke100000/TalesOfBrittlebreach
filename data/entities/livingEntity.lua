local e = extend("collidingEntity")

function e:new(position)
	e.super.new(self, position)
	
	self.health = 20
end

function e:damage(damage, attacker)
	self.health = self.health - damage
end

return e