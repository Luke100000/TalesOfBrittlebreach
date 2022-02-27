local e = extend("entity")

model = dream:loadObject("objects/player", {callback = function(model)
	model:setVertexShader("bones")
end})
model:print()

anim = model

function e:draw()
	local pose = anim.animations.Armature:getPose(love.timer.getTime())
	model:applyPose(pose)
	model:reset()
	model:scale(1 / 100)
	model:translate(5, 0, 0)
	dream:draw(model)
end

function e:update(dt)
	
end

return e