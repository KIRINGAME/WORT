
-------------------------------------------------------------------------------------------------
-- chess
local lg = love.graphics
local chess = {}
chess.__index = chess
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
local ResPath = "res/gui/"
function chess:draw( r,g,b )
	if self.bg_visible then
		lg.setColor(r,g,b,1.0)
		lg.draw(self.bg, self.x, self.y, 0 , self.size/self.bg_width, self.size/self.bg_height)
	end
	
	if self.text_visible then
		lg.setColor(0.0,0.0,0.0,1.0)
		lg.draw(self.font, self.text_x, self.text_y)
	end
end
function chess:update( dt )
	
end
-------------------------------------------------
-- 棋子的坐标x、坐标y、边长、文本、字体文件、字体大小、背景图片
function chess.new( x,y, size, text, font_file, font_size, bg, touch, text_visible, bg_visible)
	local c = setmetatable({},chess)
	c.touch = touch
	c.x = x
	c.y = y
	c.size = size
	c.text = text
	c.font_size = font_size
	c.font_file = font_file
	c.font = lg.newText(lg.newFont(ResPath..c.font_file, c.font_size),c.text)
	c.text_x = c.x + (c.size - c.font:getWidth())/2
	c.text_y = c.y + (c.size - c.font:getHeight())/2
	if bg ~= nil then
		c.bg = lg.newImage(ResPath..bg)
		c.bg_width,c.bg_height = c.bg:getDimensions()
	else
		c.bg = nil
		c.bg_width,c.bg_height = nil,nil
	end
	if text_visible~=nil then
		c.text_visible = text_visible
	else
		c.text_visible = true
	end
	if bg_visible~=nil then
		c.bg_visible = bg_visible
	else
		c.bg_visible = false
	end
	return c
end
function chess:align(x,y,size,font_size)
	if x ~= nil then
		self.x = x
	end
	if y ~= nil then
		self.y = y
	end
	if size ~= nil then
		self.size = size
	end
	if font_size~=nil then
		self.font_size = font_size
		self.font = lg.newText(lg.newFont(ResPath..self.font_file, self.font_size),self.text)
	end
	self.text_x = self.x + (self.size - self.font:getWidth())/2
	self.text_y = self.y + (self.size - self.font:getHeight())/2
end
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
return chess