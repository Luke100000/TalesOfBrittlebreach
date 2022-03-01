local extendFrom
function extend(from, i)
	local limiter = 1024
	while not extendFrom[from] do
		coroutine.yield()
		limiter = limiter - 1
		if limiter < 0 then
			error("Circular or missing dependency '" .. tostring(from) .. "'!")
		end
	end
	i = i or { }
	i.super = extendFrom[from]
	return setmetatable(i, {__index = extendFrom[from]})
end

function loadPackage(package)
	data[package] = { }
	extendFrom = data[package]
	
	local files = love.filesystem.getDirectoryItems("data/" .. package)
	
	--create coroutines
	local coroutines = { }
	for d,s in ipairs(files) do
		local chunk, errormsg = love.filesystem.load("data/" .. package .. "/" .. s)
		if chunk then
			coroutines[d] = coroutine.create(chunk)
		else
			error("Error in " .. package .. " file '" .. s .. "': " .. errormsg)
		end
	end
	
	--execute them
	while #files > 0 do
		for fid = #files, 1, -1 do
			local ok, b = coroutine.resume(coroutines[fid])
			if ok then
				if b then
					local p = files[fid]
					data[package][p:sub(1, #p-4)] = b
					
					table.remove(coroutines, fid)
					table.remove(files, fid)
				end
			else
				error("Error while loading " .. package .. " '" .. files[fid] .. "': " .. tostring(b) .. "\n" .. debug.traceback(coroutines[fid]))
			end
		end
	end
end

data = { }

loadPackage("entities")
loadPackage("bullets")