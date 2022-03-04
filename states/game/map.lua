function states.game:drawMap()
	love.graphics.push()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
	love.graphics.scale(love.mouse.isDown(3) and 40 or 10)
	love.graphics.translate(-self.player.position.x, -self.player.position.z)
	love.graphics.setLineWidth(1/16)
	love.graphics.setLineJoin("none")
	
	local sum = 0
	local centerX = 0
	local centerY = 0
	
	if states.game.map then
		for _,shape in ipairs(states.game.map) do
			local x1, y1, x2, y2, x3, y3 = unpack(shape)
			centerX = centerX + (x1 + x2 + x3) / 3
			centerY = centerY + (y1 + y2 + y3) / 3
			love.graphics.polygon("line", x1, y1, x2, y2, x3, y3)
			sum = sum + 1
		end
	end
	
	centerX = centerX / sum
	centerY = centerY / sum
	
	for _,e in ipairs(self.entities) do
		love.graphics.setColor(1, 0, 1)
		love.graphics.circle("line", e.position.x, e.position.z, 0.5)
	end
	
	if self.debugNodes then
		for d,s in ipairs(self.debugNodes) do
			if s then
				love.graphics.setColor(1, 1, 1, 0.5)
				love.graphics.circle("fill", s.x, s.y, 0.1)
				for i,v in ipairs(s.marks) do
					if v < 0 then
						local n = self.debugNodes[s.neighbours[i]]
						love.graphics.setLineWidth(0.1)
						love.graphics.setColor(0, 1, 0)
						love.graphics.line(s.x, s.y, n.x, n.y)
					elseif v > 0 then
						local n = self.debugNodes[s.neighbours[i]]
						love.graphics.setLineWidth(0.1)
						love.graphics.setColor(1, 0, 0)
						love.graphics.line(s.x, s.y, n.x, n.y)
					end
				end
			end
		end
	end
	
	love.graphics.pop()
	
	return sum
end