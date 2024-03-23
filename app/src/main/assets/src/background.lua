
local background = {}
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
local BgPath 		=   "res/gui/img/bg/bg"
local MAX_PIC       =   232
local IMG_WIDTH		=	720
local IMG_HEIGHT	=	1280
local w,h,factor

function background.load()
    -- 取等比缩放的效果
	w = love.graphics.getWidth()
	h = love.graphics.getHeight()
    local factor_x = w/IMG_WIDTH
    local factor_y = h/IMG_HEIGHT
    factor = factor_x
    if factor_x < factor_y then
        factor = factor_y
    end
    background.reset()
end

function background.draw()
	if background.enable_draw == false then
		return
	end
	if background.background_image ~=nil then
	    love.graphics.draw(background.background_image, 0, 0, 0, factor, factor)
    end
end

-------------------------------------------------------------------------------------------------


function background.reset()
	---------------------------------------------------------------------------
	-- random img
	---------------------------------------------------------------------------

	if background.background_image ~=nil then
		background.background_image:release()
	end
	local id = math.random(1,MAX_PIC)
	local str = string.format(BgPath.."%03d.jpg",id)
	background.background_image = love.graphics.newImage(str)
	
    -- for id=1,MAX_PIC do
    --     local str = string.format(BgPath.."%03d.jpg",id)
    --     background.background_image = love.graphics.newImage(str)
    -- end
end

-------------------------------------------------------------------------------------------------
-- 辅助函数
function background.set_enable_draw( flag )
	background.enable_draw = flag
end
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
return background;