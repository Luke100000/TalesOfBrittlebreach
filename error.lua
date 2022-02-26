--enable debug mode
DEBUGENABLED = love.filesystem.read("debugEnabled") == "true"

--base64 for errors
local base64_mime = require("mime")
local base64_encode_func = base64_mime.encode("base64")
local base64_encode = function(d)
	local res = base64_encode_func(d):gsub("+", "%%2B")
	return res
end

--register game to lovun
local gameInfo = { }
local function registerGame(name, version, username)
	gameInfo.name = name
	gameInfo.version = version
	gameInfo.username = username or "unknown"
end
registerGame("unknown", "2.0")

--http thread to send error log
local channel_send = love.thread.getChannel("error_thread_send")
local channel_receive = love.thread.getChannel("error_thread_receive")
local thread = love.thread.newThread([[
	channel_send = love.thread.getChannel("error_thread_send")
	channel_receive = love.thread.getChannel("error_thread_receive")
	
	local http = require("socket.http")
	while true do
		local msg = channel_send:demand()
		if msg == "terminate" then return end
		if msg then
			local r = http.request(msg[1] .. "?" .. msg[2])
			channel_receive:push(r)
		end
	end
]], channel_send)

--log
local printLog = { }
local printOld = print
local printBuffer = 1024
local printBufferClear = 64
print = function(...)
	if DEBUGENABLED then
		printOld(...)
	else
		--tostring
		local t = { }
		for d,s in ipairs({...}) do
			t[#t+1] = tostring(s)
		end
		
		--logging
		table.insert(printLog, table.concat(t, "\t"))
		if #printLog > printBuffer + printBufferClear then
			for i = 1, printBufferClear do
				table.remove(printLog, 1)
			end
		end
	end
end

--fonts
local fonts = {
	big = love.graphics.newFont(32),
	medium = love.graphics.newFont(24),
}

--draw function
local errorReceived = false
local function draw(fancyMsg)
	love.graphics.origin()
	love.graphics.translate((love.graphics.getWidth()-800) / 2, (love.graphics.getHeight()-450) / 2)
	love.graphics.clear(love.graphics.getBackgroundColor())
	
	love.graphics.setColor(1.0, 1.0, 1.0, 0.2)
	love.graphics.rectangle("fill", 10, 10, 780, 430, 5)
	love.graphics.setColor(0.1, 0.1, 0.1, 0.2)
	love.graphics.rectangle("line", 10, 10, 780, 430, 5)
	
	--Oh no!
	love.graphics.setColor(0.1, 0.1, 0.1)
	love.graphics.setFont(fonts.big)
	love.graphics.printf("Oh no! " .. love.window.getTitle() .. " crashed!", 0, 70, 800, "center")
	
	love.graphics.line(150, 130, 650, 130)
	
	love.graphics.setFont(fonts.medium)
	love.graphics.printf("Game progress should be saved.\n\nThis error log will be sent automatically to the developer, so this bug can be fixed as soon as possible.", 80, 160, 640, "center")
	
	--uploading progress
	love.graphics.setFont(fonts.medium)
	if DEBUGENABLED then
		love.graphics.setColor(0.1, 0.1, 0.1)
		love.graphics.printf("debug enabled", 0, 350, 800, "center")
	elseif errorReceived then
		love.graphics.setColor(0.1, 0.8, 0.1)
		love.graphics.printf("error uploaded!", 0, 350, 800, "center")
	elseif errorReceived == nil then
		love.graphics.setColor(0.1, 0.6, 0.6)
		love.graphics.printf("server not available.", 0, 350, 800, "center")
	else
		love.graphics.setColor(0.8, 0.1, 0.1)
		local anim = math.floor(love.timer.getTime()*2)
		local anim_string = 
		love.graphics.printf("uploading error" .. string.rep(".", anim - math.floor(anim/4)*4), 0, 340, 800, "center")
	end
	
	love.graphics.present()
end

local function handler(msg)
	local fancyMsg = (debug.traceback("Error: " .. tostring(msg), 1):gsub("\n[^\n]+$", ""))
	
	--crop irrelevant things out
	local start = string.find(fancyMsg, "err.lua:114: in function <error.lua:", 0, true)
	local end_ = string.find(fancyMsg, [==[[string "boot.lua"]:777: in function <[string "boot.lua"]==], 0, true)
	if start and end_ then
		fancyMsg = fancyMsg:sub(0, start-1) .. fancyMsg:sub(end_+64)
	end
	
	--device
	local name, version, vendor, device = love.graphics.getRendererInfo()
	local deviceMsg = "name: " .. tostring(name) .. "\nversion: " .. tostring(version) .. "\nvendor: " .. tostring(vendor) .. "\ndevice: " .. tostring(device)
	
	--fance error
	printOld("\n" .. fancyMsg .. "\n")
	fancyMsg = fancyMsg:gsub("\t", "") .. "\n\n" .. deviceMsg
	
	if DEBUGENABLED then
		--os.exit()
	end
	
	--detailed error
	love.timer.sleep(1/100)
	local fancyMsgDetailed = fancyMsg .. "\n\nCLIENT LOG START\n" .. table.concat(printLog, "\n")
	fancyMsgDetailed = fancyMsgDetailed:sub(1, 1024 * 1024)
	
	--early exit if graphic feature failed
	if not love.window or not love.graphics or not love.event then
		return
	end
	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end
	
	--reset mouse state
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
	end
	
	--stop audio
	if love.audio then
		love.audio.stop()
	end
	
	--reset view
	love.graphics.reset()
	love.graphics.setBackgroundColor(0.8, 0.8, 0.8)
	
	if not DEBUGENABLED then
		--start thread if offline
		if not thread:isRunning() then
			thread:start()
		end
		
		--upload error
		channel_send:push({"https://katzmair.eu/~luke100000/lovum/error.php",
			"game=" .. gameInfo.name:gsub(" ", "") ..
			"&version=" .. gameInfo.version:gsub(" ", "") ..
			"&username=" .. gameInfo.username:gsub(" ", "") ..
			"&error=" .. base64_encode(fancyMsgDetailed)}
		)
	end
	
	while true do
		love.event.pump()
		
		for e, a, b, c in love.event.poll() do
			if e == "quit" or (e == "keypressed" and a == "escape") then
				if love.quit then
					love.quit(true)
				end
				return
			end
		end
		
		--draw
		draw(fancyMsg)
		
		--upload process
		if not DEBUGENABLED and not errorReceived then
			local msg = channel_receive:pop()
			if msg then
				if msg == "error received" then
					errorReceived = true
				else
					errorReceived = nil
				end
			end
		end
		
		if love.timer then
			love.timer.sleep(1/60)
		end
	end
end

--error handler
function love.errhand(msg)
	local ok, criticalErrMsg = pcall(handler, tostring(msg))
	if not ok then
		print("error handler failed")
		print(criticalErrMsg)
	end
end

return registerGame