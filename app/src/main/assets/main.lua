require("lib")
local update_mgr = require("update/update_mgr")
local game = require("src/game")

-----------------------------------
function love.touchpressed( id, x, y, dx, dy, pressure )

end
function love.touchreleased( id, x, y, dx, dy, pressure )

end
function love.touchmoved( id, x, y, dx, dy, pressure )

end
function love.mousepressed( x, y, button, istouch, presses )
    if update_mgr.is_updateing() then
	    update_mgr.event_process(event_type.down,x,y,button,istouch,presses)
    else
        game.event_process(event_type.down,x,y,button,istouch,presses)
    end
end
function love.mousereleased( x, y, button, istouch, presses )
    if update_mgr.is_updateing() then
	    update_mgr.event_process(event_type.up,x,y,button,istouch,presses)
    else
        game.event_process(event_type.up,x,y,button,istouch,presses)
    end
end
function love.mousemoved( x, y, button, istouch, presses )
    if update_mgr.is_updateing() then
	    update_mgr.event_process(event_type.move,x,y,button,istouch,presses)
    else
        game.event_process(event_type.move,x,y,button,istouch,presses)
    end
end
function love.keypressed(key, scancode, isrepeat )
    if update_mgr.is_updateing() then
	    update_mgr.keypressed(key, scancode, isrepeat )
    else
        game.keypressed(key, scancode, isrepeat )
    end
end
-------------------------------------------------------------------------------------------------
function love.load()
    love.window.setFullscreen(true, "desktop")
    -- 更新模块
    update_mgr.init()
end
function love.update( dt )
	timer.update(dt)
    -- 更新模块
    if not update_mgr.tick(dt) then
        game.update(dt)
    end
end

function love.draw()	
    if not update_mgr.draw() then
        game.draw()
    end
end

function quit()
    love.event.quit()
end
