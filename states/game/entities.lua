function states.game:newEntity(typ, x, y, z)
	local dat = data.entities[typ]
	local e = setmetatable({ },	{__index = dat})
	e:new(vec3(x, y, z))
	table.insert(self.entities, e)
	return e
end

function states.game:drawEntities()
	for d,s in ipairs(self.entities) do
		s:draw()
	end
end

function states.game:updateEntities(dt)
	for d = #self.entities, 1, -1 do
		local s = self.entities[d]
		local remove = s:update(dt)
		if remove then
			table.remove(self.entities, d)
		end
	end
end