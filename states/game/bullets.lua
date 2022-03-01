function states.game:newBullet(typ, ...)
	local dat = data.bullets[typ]
	local e = setmetatable({ },	{__index = dat})
	e.id = states.game:getId()
	e:new(...)
	table.insert(self.bullets, e)
	return e
end

function states.game:drawBullets()
	for d,s in ipairs(self.bullets) do
		s:draw()
	end
end

function states.game:updateBullets(dt)
	for d = #self.bullets, 1, -1 do
		local s = self.bullets[d]
		local remove = s:update(dt)
		if remove then
			table.remove(self.bullets, d)
		end
	end
end