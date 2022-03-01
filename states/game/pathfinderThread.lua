local inputChannel, outputChannel = ...

local nodes
local nodeTable
local dimensions

local function init(x1, y1, x2, y2, resolution)
	nodes = { }
	nodeTable = { }
	
	dimensions = {
		x1 = x1,
		y1 = y1,
		x2 = x2,
		y2 = y2,
		resolution = resolution
	}
	
	--setup nodes
	local w = math.ceil((x2 - x1) / resolution)
	local h = math.ceil((y2 - y1) / resolution)
	for x = 1, w do
		nodeTable[x] = { }
		for y = 1, h do
			local n = {
				x = (x / w) * (x2 - x1) + x1,
				y = (y / h) * (y2 - y1) + y1,
				id = #nodes + 1,
				weights = { },
				marks = { },
				neighbours = { }
			}
			table.insert(nodes, n)
			nodeTable[x][y] = n
		end
	end
	
	--add children
	for x = 1, w do
		for y = 1, h do
			local node = nodeTable[x][y]
			for cx = -1, 1 do
				for cy = -1, 1 do
					if cx ~= 0 or cy ~= 0 then
						local fx = x + cx
						local fy = y + cy
						local neighbour = nodeTable[fx] and nodeTable[fx][fy]
						if neighbour then
							table.insert(node.neighbours, neighbour.id)
							table.insert(node.weights, math.abs(cx) + math.abs(cy))
							table.insert(node.marks, 0)
						end
					end
				end
			end
		end
	end
end

local function getNodeAt(x, y)
	local gx = math.floor((x - dimensions.x1) / dimensions.resolution + 0.5)
	local gy = math.floor((y - dimensions.y1) / dimensions.resolution + 0.5)
	return nodeTable[gx] and nodeTable[gx][gy]
end

local function findPath(x, y, tx, ty)
	--find initial node
	local node = getNodeAt(x, y)
	if not node then
		return false
	end
	
	local targetNode = tx and getNodeAt(tx, ty)
	
	local todo = {{node}}
	local bucketIndex = 1
	local entryIndex = 1
	local totalBuckets = 1
	local best = {[node] = 1}
	local backtrace = { }
	local transitions = 0
	while bucketIndex <= totalBuckets do
		local node = todo[bucketIndex] and todo[bucketIndex][entryIndex]
		
		--spread
		if node and best[node] == bucketIndex then
			for ni, neighbourId in ipairs(node.neighbours) do
				local neighbour = nodes[neighbourId]
				local weight = bucketIndex + node.weights[ni] + (node.marks[ni] > 0 and 100 or 0)
				if not best[neighbour] or best[neighbour] > weight then
					best[neighbour] = weight
					backtrace[neighbour] = {node, ni}
					
					totalBuckets = math.max(totalBuckets, weight)
					todo[weight] = todo[weight] or { }
					table.insert(todo[weight], neighbour)
					
					if neighbour == targetNode then
						goto done
					end
				end
			end
		end
		
		transitions = transitions + 1
		entryIndex = entryIndex + 1
		if not node or entryIndex > #todo[bucketIndex] then
			entryIndex = 1
			bucketIndex = bucketIndex + 1
		end
	end
	
	::done::
	
	if tx then
		--find target
		targetNode = getNodeAt(tx, ty)
		if not backtrace[targetNode] then
			local minDistance = math.huge
			for node, _ in pairs(backtrace) do
				local distance = (node.x - tx)^2 + (node.y - ty)^2
				if distance < minDistance then
					minDistance = distance
					targetNode = node
				end
			end
		end
	else
		--find random target
		local count = 0
		for node, _ in pairs(backtrace) do
			count = count + 1
		end
		count = math.random(1, count)
		for node, _ in pairs(backtrace) do
			count = count - 1
			if count <= 0 then
				targetNode = node
				break
			end
		end
	end
	
	--backtrace
	if targetNode then
		local path = { }
		while backtrace[targetNode] do
			table.insert(path, 1, {
				targetNode.x,
				targetNode.y,
				backtrace[targetNode][1].id,
				backtrace[targetNode][2],
			})
			targetNode = backtrace[targetNode][1]
		end
		return path
	else
		return false
	end
end

while true do
	local task = inputChannel:demand()
	
	if task[1] == "init" then
		init(unpack(task, 2))
	elseif task[1] == "mark" then
		local marks = nodes[task[2]].marks
		marks[task[3]] = marks[task[3]] + task[4]
	elseif task[1] == "debug" then
		outputChannel:push({
			nodes = nodes
		})
	elseif task[1] == "find" then
		local path = findPath(unpack(task, 3))
		outputChannel:push({
			ID = task[2],
			path = path
		})
	end
end