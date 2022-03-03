local thread = love.thread.newThread("states/game/physicsThread.lua")
local inputChannel = love.thread.newChannel()
local resultChannel = love.thread.newChannel()

thread:start(inputChannel, resultChannel)

local lagging = false

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

function states.game:applyForce(entity, fx, fy)
	if not lagging then
		inputChannel:push({"force", entity.physicsId, fx, fy})
	end
end

function states.game:updatePhysics(dt)
	if inputChannel:getCount() == 0 then
		inputChannel:push({"update", dt})
		lagging = false
	else
		lagging = true
	end
	
	while resultChannel:getCount() > 0 do
		local task = resultChannel:pop()
		if task.physicsId then
			dynamics[task.physicsId].position = vec3(task.position)
			dynamics[task.physicsId].velocity = vec3(task.velocity)
			dynamics[task.physicsId].collided = task.collided
		elseif task.dt then
			states.game.physicsUtilisation = states.game.physicsUtilisation * (1 - dt) + task.dt
		end
	end
end