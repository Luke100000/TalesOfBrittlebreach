local sum = 0
local centerX = 0
local centerY = 0

local function draw(c)
	if c.body then
		for _,fixture in ipairs(c.body:getFixtures()) do
			local shape = fixture:getShape()
			local x1, y1, x2, y2, x3, y3 = c.body:getWorldPoints(shape:getPoints())
			centerX = centerX + (x1 + x2 + x3) / 3
			centerY = centerY + (y1 + y2 + y3) / 3
			love.graphics.polygon("line", x1, y1, x2, y2, x3, y3)
			sum = sum + 1
		end
	else
		for d,s in ipairs(c) do
			draw(s)
		end
	end
end

function states.game:drawMap()
	love.graphics.push()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
	love.graphics.scale(love.mouse.isDown(3) and 40 or 10)
	love.graphics.translate(-self.player.position.x, -self.player.position.z)
	love.graphics.setLineWidth(1/16)
	love.graphics.setLineJoin("none")
	
	sum = 0
	centerX = 0
	centerY = 0
	
	draw(self.worldCollider)
	
	centerX = centerX / sum
	centerY = centerY / sum
	
	for _,e in ipairs(self.entities) do
		if e.collider then
			local shape = e.collider.body:getFixtures()[1]:getShape()
			local x, y = e.collider.body:getWorldPoints(0, 0)
			love.graphics.circle("line", x, y, shape:getRadius() * 2)
		end
	end
	
	if self.debugNodes then
		for d,s in ipairs(self.debugNodes) do
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
	
	love.graphics.pop()
	
	return sum
end