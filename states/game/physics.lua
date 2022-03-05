local thread = love.thread.newThread("states/game/physicsThread.lua")
local inputChannel = love.thread.newChannel()
local resultChannel = love.thread.newChannel()

thread:start(inputChannel, resultChannel)

local lagging = 0

function states.game:loadPhysicsObject(path)
	inputChannel:push({"load", path})
end

local physicsId = 0
local dynamics = { }
function states.game:addDynamics(entity, radius, size)
	physicsId = physicsId + 1
	entity.physicsId = physicsId
	dynamics[physicsId] = entity
	inputChannel:push({"add", physicsId, radius, size, entity.position.x, entity.position.y, entity.position.z})
end

function states.game:removeDynamics(entity)
	dynamics[physicsId] = nil
	inputChannel:push({"remove", physicsId})
end

function states.game:applyForce(entity, fx, fy)
	if lagging == 0 then
		inputChannel:push({"force", entity.physicsId, fx, fy})
	end
end

function states.game:updatePhysics(dt)
	lagging = lagging + dt
	if inputChannel:getCount() == 0 then
		inputChannel:push({"update", math.min(1 / 10, lagging)})
		lagging = 0
	end
	
	while resultChannel:getCount() > 0 do
		local task = resultChannel:pop()
		if task.physicsId and dynamics[task.physicsId] then
			dynamics[task.physicsId].position = vec3(task.position)
			dynamics[task.physicsId].velocity = vec3(task.velocity)
			dynamics[task.physicsId].collided = task.collided
		elseif task.dt then
			states.game.physicsUtilisation = states.game.physicsUtilisation * (1 - dt) + task.dt
		elseif task.map then
			self.map = task.map
		end
	end
end