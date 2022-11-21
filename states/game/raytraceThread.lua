local inputChannel, outputChannel = ...

--load libraries
local dream = require("3DreamEngine")

local raytrace = require("extensions/raytrace")

dream:loadMaterialLibrary("materials")

dream:loadLibrary("objects/libraries/buildings", { mesh = false, cleanup = false })
dream:loadLibrary("objects/libraries/buildings_castle", { mesh = false, cleanup = false }, "castle_")
dream:loadLibrary("objects/libraries/furniture", { mesh = false, cleanup = false })
dream:loadLibrary("objects/libraries/nature", { mesh = false, cleanup = false })
dream:loadLibrary("objects/libraries/plants", { mesh = false, cleanup = false })

--stores meshes
local objects = { }

while true do
	local task = inputChannel:demand()
	
	if task[1] == "set" then
		error("not implemented")
	elseif task[1] == "load" then
		objects[task[2]] = dream:loadScene(task[2], { cleanup = false, mesh = false })
	elseif task[1] == "raytrace" then
		local bestDistance = math.huge
		local a, b = vec3(task[3]), vec3(task[4])
		local result
		for _, s in pairs(objects) do
			local r = raytrace:cast(s, a, b)
			if r then
				if r:getDistance() < bestDistance then
					bestDistance = r:getDistance()
					result = r
				end
			end
		end
		
		if result then
			outputChannel:push({
				ID = task[2],
				pos = result:getPosition(),
				normal = result:getNormal(),
			})
		else
			outputChannel:push({
				ID = task[2],
			})
		end
	end
end