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
dream:loadMaterialLibrary("materials")

dream:init()

require("states/load/data")