local raytraceInputChannel, raytraceResultChannel = ...

--load libraries
local dream = require("3DreamEngine")

local raytrace = require("extensions/raytrace")

--stores meshes
local objects = { }

--from the transform class
local getInvertedTransform = function(obj)
	if not obj.inverseTransform then
		obj.inverseTransform = obj.transform:invert()
	end
	return obj.inverseTransform
end

while true do
	local task = raytraceInputChannel:demand()
	
	if task[1] == "set" then
		error("not implemented")
	elseif task[1] == "load" then
		objects[task[2]] = dream:loadScene(task[2], {cleanup = false, mesh = false})
	elseif task[1] == "raytrace" then
		local bestT = math.huge
		local bestU, bestV, bestF
		local bestObjectName, bestObject, bestPos
		local a, b = vec3(task[3]), vec3(task[4])
		
		for d,s in pairs(objects) do
			local pos = raytrace:raytrace(s, a, b)
			if pos then
				local maxT, maxU, maxV, maxF = raytrace:getResult()
				if maxT < bestT then
					bestT, bestU, bestV, bestF = maxT, maxU, maxV, maxF
					bestObjectName, bestPos = d, pos
					bestObject = raytrace:getObject()
				end
			end
		end
		
		if bestObjectName then
			raytraceResultChannel:push({
				ID = task[2],
				pos = bestPos,
				normal = raytrace:getNormal(bestObject, bestU, bestV, bestF),
				object = bestObjectNmae,
				t = bestT,
				u = bestU,
				v = bestV,
				f = bestF
			})
		else
			raytraceResultChannel:push({
				ID = task[2],
			})
		end
	end
end