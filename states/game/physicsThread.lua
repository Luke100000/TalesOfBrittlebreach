local inputChannel, outputChannel = ...

require("love.physics")
require("love.timer")

--load libraries
local dream = require("3DreamEngine")

local physics = require("extensions/physics")

dream:loadMaterialLibrary("materials")

dream:loadLibrary("objects/libraries/buildings", {mesh=false, cleanup=false})
dream:loadLibrary("objects/libraries/buildings_castle", {mesh=false, cleanup=false}, "castle_")
dream:loadLibrary("objects/libraries/furniture", {mesh=false, cleanup=false})
dream:loadLibrary("objects/libraries/nature", {mesh=false, cleanup=false})
dream:loadLibrary("objects/libraries/plants", {mesh=false, cleanup=false})

--physics world
local physicsWorld = physics:newWorld()

local colliders = { }

while true do
	local task = inputChannel:demand()
	
	if task[1] == "set" then
		error("not implemented")
	elseif task[1] == "load" then
		local object = dream:loadScene(task[2], {cleanup = false, mesh = false})
		
		--setup physics
		local collider = physicsWorld:add(physics:newMesh(object))
		
		outputChannel:push({
			ID = task[2],
		})
	elseif task[1] == "add" then
		colliders[task[2]] = physicsWorld:add(physics:newCircle(task[3], task[4]), "dynamic", task[5], task[6], task[7])
	elseif task[1] == "force" then
		colliders[task[2]]:applyForce(task[3], task[4])
	elseif task[1] == "update" then
		local time = love.timer.getTime()
		physicsWorld:update(task[2])
		
		outputChannel:push({
			dt = love.timer.getTime() - time
		})
		
		for physicsId, collider in pairs(colliders) do
			outputChannel:push({
				physicsId = physicsId,
				position = collider:getPosition(),
				velocity = collider:getVelocity(),
				collided = collider.collided
			})
		end
	end
end