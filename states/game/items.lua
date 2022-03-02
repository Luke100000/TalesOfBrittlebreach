function states.game:newItem(typ, position)
	local dat = data.items[typ]
	local e = setmetatable({ },	{__index = dat})
	e.id = states.game:getId()
	e:new(position)
	table.insert(self.items, e)
	return e
end

function states.game:drawItems()
	for d,s in ipairs(self.items) do
		s:draw()
	end
end

function states.game:updateItems(dt)
	for d = #self.items, 1, -1 do
		local s = self.items[d]
		local remove = s:update(dt)
		if remove then
			table.remove(self.items, d)
		end
	end
end

function states.game:findNearestItem(position)
	local best = math.huge
	local nearest
	for d,s in ipairs(states.game.items) do
		local dist = (s.position - position):lengthSquared()
		if dist < best then
			best = dist
			nearest = s
		end
	end
	return nearest, best
end