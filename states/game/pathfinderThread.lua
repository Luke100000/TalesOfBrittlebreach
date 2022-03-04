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
				x = (x / w) * (x2 - x1) + x1 + (math.random() - 0.5) * 0.25,
				y = (y / h) * (y2 - y1) + y1 + (math.random() - 0.5) * 0.25,
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

local function getNodePositionAt(x, y)
	local gx = math.floor((x - dimensions.x1) / dimensions.resolution + 0.5)
	local gy = math.floor((y - dimensions.y1) / dimensions.resolution + 0.5)
	return gx, gy
end
local function getNodeAt(x, y)
	local gx, gy = getNodePositionAt(x, y)
	return nodeTable[gx] and nodeTable[gx][gy]
end
local collisionPreparer = love.thread.getChannel("pathfinderBlockingChannel")

local function removeNode(node)
	for _,nid in ipairs(node.neighbours) do
		local n = nodes[nid]
		for i = #n.neighbours, 1, -1 do
			if n.neighbours[i] == node.id then
				table.remove(n.neighbours, i)
			end
		end
	end
	nodes[node.id] = false
	local gx, gy = getNodePositionAt(node.x, node.y)
	if nodeTable[gx] then
		nodeTable[gx][gy] = nil
	end
end

local function sign(x1, y1, x2, y2, x3, y3)
    return (x1 - x3) * (y2 - y3) - (x2 - x3) * (y1 - y3)
end

local function PointInTriangle(x, y, x1, y1, x2, y2, x3, y3)
    local d1 = sign(x, y, x1, y1, x2, y2)
    local d2 = sign(x, y, x2, y2, x3, y3)
    local d3 = sign(x, y, x3, y3, x1, y1)

    local has_neg = (d1 < 0) or (d2 < 0) or (d3 < 0)
    local has_pos = (d1 > 0) or (d2 > 0) or (d3 > 0)

    return not (has_neg and has_pos)
end

local function findPath(x, y, tx, ty, maxTransitions)
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
	while bucketIndex <= totalBuckets and (not maxTransitions or transitions < maxTransitions) do
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

local function expand(cx, cy, x, y)
	local dx = x - cx
	local dy = y - cy
	local d = math.sqrt(dx^2 + dy^2)
	local f = 0.25
	return x + dx / d * f, y + dy / d * f
end

while true do
	if nodeTable then
		local p = collisionPreparer:pop()
		if p then
			for d,s in ipairs(p) do
				local x1, y1, x2, y2, x3, y3 = unpack(s)
				local cx = (x1 + x2 + x3) / 3
				local cy = (y1 + y2 + y3) / 3
				x1, y1 = expand(cx, cy, x1, y1)
				x2, y2 = expand(cx, cy, x2, y2)
				x3, y3 = expand(cx, cy, x3, y3)
				for x = math.min(x1, x2, x3), math.max(x1, x2, x3) + dimensions.resolution, dimensions.resolution do
					for y = math.min(y1, y2, y3), math.max(y1, y2, y3) + dimensions.resolution, dimensions.resolution do
						local node = getNodeAt(x, y)
						if node and PointInTriangle(node.x, node.y, x1, y1, x2, y2, x3, y3) then
							removeNode(node)
						end
					end
				end
			end
		end
	end
	
	local task = inputChannel:demand()
	
	if task[1] == "init" then
		init(unpack(task, 2))
	elseif task[1] == "mark" then
		if nodes[task[2]] then
			local marks = nodes[task[2]].marks
			marks[task[3]] = marks[task[3]] + task[4]
		end
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