screen = { }
screen.w = love.graphics.getWidth()
screen.h = love.graphics.getHeight()

--holds the last pressed button since the last tick
mousepressed_button = false
mousereleased_button = false
keypressed_button = false
mousewheel_button = false

math.randomseed(os.time())

love.keyboard.setKeyRepeat(false)
love.graphics.setLineStyle("rough")
love.graphics.setBackgroundColor(0, 0, 0)
love.graphics.setLineJoin("bevel")

io.stdout:setvbuf("no")

dream = require("3DreamEngine")
dream.defaultArgs.export3do = true

dream:loadMaterialLibrary("materials")

dream:loadLibrary("objects/libraries/buildings")
dream:loadLibrary("objects/libraries/buildings_castle", nil, "castle_")
dream:loadLibrary("objects/libraries/furniture")
dream:loadLibrary("objects/libraries/nature")
dream:loadLibrary("objects/libraries/plants")

dream:init()

require("states/load/data")

data.animations = { }
for d,s in ipairs(love.filesystem.getDirectoryItems("objects/animations")) do
	if s:sub(-4) == ".dae" then
		local name = s:sub(1, -5)
		local o = dream:loadObject("objects/animations/" .. name)
		data.animations[name] = o.animations.Default or o.animations.Armature
	end
end