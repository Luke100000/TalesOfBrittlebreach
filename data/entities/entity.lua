local e = { }

function e:new(position)
	self.position = position
end

function e:draw()

end

function e:update(dt)
	if self.position.y < -10 then
		return true
	end
	return self.health <= 0 and (not self.dieTimer or self.dieTimer > 1)
end

function e:control(dt)
	
end

function e:damage(damage, attacker)
	
end

return e