local UI = require ("lib/UI")
local gui = setmetatable({}, UI)
_G["gui"] = gui

function gui.init()
    
	UI.init("res/gui/")
	UI.set_window(540,960)
	UI.load_script("main_script.xml")
    UI.load_ref("main_ref.xml")
    UI.load_font("main_font.xml")
	UI.load_ui("main_ui.xml")
end

function gui.draw()
	UI.draw()

	-- local osString = love.system.getOS( )
	-- if osString == "Android" or osString == "iOS" then
	-- else
	-- 	love.graphics.setFont(UI.default_font)
	-- 	local fps = love.timer.getFPS()
	-- 	love.graphics.setColor(1, 0, 0)
	-- 	love.graphics.print('FPS: ' .. love.timer.getFPS(), 0, 0)
	-- 	love.graphics.print('Memory: ' .. math.floor(collectgarbage 'count') .. ' kb', 0, 16)
	-- 	love.graphics.setColor(1, 1, 1)
	-- end
end

---------------------------------------
--外部调用接口
-------------------------------------------------------------------------------------------------

function GET_UI()
	return gui
end
function GET_UIROOT()
	return gui.root
end
return gui