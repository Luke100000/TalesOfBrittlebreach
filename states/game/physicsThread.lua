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

local map
local function createMap(c)
	if c.body then
		local h = 0
		for d,s in ipairs(c.shape.highest) do
			h = h + s[1] + s[2] + s[3]
		end
		h = h / #c.shape.highest / 3
		
		local l = 0
		for d,s in ipairs(c.shape.lowest) do
			l = l + s[1] + s[2] + s[3]
		end
		l = l / #c.shape.lowest / 3
		
		if h > 0.5 and l < 0.1 then
			for _,fixture in ipairs(c.body:getFixtures()) do
				local shape = fixture:getShape()
				table.insert(map, {c.body:getWorldPoints(shape:getPoints())})
			end
		end
	else
		for d,s in ipairs(c) do
			createMap(s)
		end
	end
end

while true do
	local t = love.timer.getTime()
	local task
	while not task do
		task = inputChannel:demand()
	end
	
	if task[1] == "set" then
		error("not implemented")
	elseif task[1] == "load" then
		local object = dream:loadScene(task[2], {cleanup = false, mesh = false})
		
		--setup physics
		local collider = physicsWorld:add(physics:newMesh(object))
		
		map = { }
		createMap(collider)
		
		love.thread.getChannel("pathfinderBlockingChannel"):push(map)
		
		outputChannel:push({
			map = map,
		})
	elseif task[1] == "add" then
		colliders[task[2]] = physicsWorld:add(physics:newCircle(task[3], task[4]), "dynamic", task[5], task[6], task[7])
	elseif task[1] == "remove" then
		if colliders[task[2]] then
			colliders[task[2]].body:destroy()
			colliders[task[2]] = nil
		end
	elseif task[1] == "force" then
		if colliders[task[2]] then
			colliders[task[2]]:applyForce(task[3], task[4])
		end
	elseif task[1] == "update" then
		local time = love.timer.getTime()
		physicsWorld:update(task[2])
		
		for physicsId, collider in pairs(colliders) do
			outputChannel:push({
				physicsId = physicsId,
				position = collider:getPosition(),
				velocity = collider:getVelocity(),
				collided = collider.collided
			})
		end
		
		outputChannel:push({
			dt = love.timer.getTime() - time
		})
	end
end