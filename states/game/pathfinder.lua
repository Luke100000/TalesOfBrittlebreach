local pathfinderThread = love.thread.newThread("states/game/pathfinderThread.lua")
local inputChannel = love.thread.newChannel()
local resultChannel = love.thread.newChannel()

pathfinderThread:start(inputChannel, resultChannel)

states.game.pathfinderResults = { }
states.game.pathfinderCallbacks = { }

local lastID = 0

inputChannel:push({"init", -40, -40, 40, 40, 0.5})

function states.game:fetchPath(id)
	if states.game.pathfinderResults[id] then
		local v = states.game.pathfinderResults[id]
		states.game.pathfinderResults[id] = nil
		return v
	end
end

function states.game:requestPath(id, x, y, tx, ty)
	if type(id) == "function" then
		lastID = lastID + 1
		local cbid = "callback_" .. lastID
		self.pathfinderCallbacks[cbid] = id
		inputChannel:push({"find", cbid, x, y, tx, ty})
	else
		inputChannel:push({"find", id, x, y, tx, ty})
	end
end

function states.game:markPath(id, ni, value)
	inputChannel:push({"mark", id, ni, value})
end

function states.game:requestPathfinderDebug()
	inputChannel:push({"debug"})
end

function states.game:updatePathfinder()
	while resultChannel:getCount() > 0 do
		local task = resultChannel:pop()
		if task.nodes then
			states.game.debugNodes = task.nodes
		else
			if self.pathfinderCallbacks[task.ID] then
				self.pathfinderCallbacks[task.ID](task.path)
				self.pathfinderCallbacks[task.ID] = nil
			else
				self.raytracerResults[task.ID] = task.path
			end
		end
	end
end