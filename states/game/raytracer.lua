local thread = love.thread.newThread("states/game/raytraceThread.lua")
local inputChannel = love.thread.newChannel()
local resultChannel = love.thread.newChannel()

thread:start(inputChannel, resultChannel)

states.game.raytracerResults = { }
states.game.raytracerCallbacks = { }

local lastID = 0

function states.game:loadRaytraceObject(path)
	inputChannel:push({"load", path})
end

function states.game:fetchRaytracerResult(id)
	if states.game.raytracerResults[id] then
		local v = states.game.raytracerResults[id]
		states.game.raytracerResults[id] = nil
		return v
	end
end

function states.game:requestRaytrace(id, origin, direction)
	if type(id) == "function" then
		lastID = lastID + 1
		local cbid = "callback_" .. lastID
		self.raytracerCallbacks[cbid] = id
		inputChannel:push({"raytrace", cbid, origin, direction})
	else
		inputChannel:push({"raytrace", id, origin, direction})
	end
end

function states.game:updateRaytracer()
	while resultChannel:getCount() > 0 do
		local task = resultChannel:pop()
		task.pos = task.pos and vec3(task.pos)
		task.normal = task.normal and vec3(task.normal)
		if self.raytracerCallbacks[task.ID] then
			self.raytracerCallbacks[task.ID](task)
			self.raytracerCallbacks[task.ID] = nil
		else
			self.raytracerResults[task.ID] = task
		end
	end
end