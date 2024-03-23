
local tween = require("lib/UI/tween")
local xml_parser = require ("lib/xml")
local peachy = require ("lib/peachy")

local lg = love.graphics

local UI = {}
UI.__index = UI

UI.root_path = nil
UI.root = nil
UI.priority_ctrl = nil

local control_type = 
{
	control 		= 0,
	panel 			= 1,
	scrollviewer 	= 2,
	label			= 3,
	image			= 4,
	animation		= 5,
	
}
local function get_control_type_name(id)
    for k, v in pairs(control_type) do
        if v == id then
            return k
        end
    end
    return nil
end
local align_func = 
{
    -- 前方注册，后方定义
}
local align_type = 
{
	align_type_scale = 1,
	align_type_stretch = 2,
}
local text_align_type = 
{
	text_align_type_x1 = 1,
	text_align_type_x2 = 2,
	text_align_type_xx = 3,
	text_align_type_y1 = 1,
	text_align_type_y2 = 2,
	text_align_type_yy = 3,
}
local image_fill_type = 
{
    image_fill_type_scale = 1,
    image_fill_type_stretch = 2,
}
event_type = 
{
	down 	= 1,
	move 	= 2,
	up		= 3,
}
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- UI 

----------------------------------------------------------------
-- control
local control = {}
control.__index = control
function control.new()
	local self = {}
	setmetatable(self, control)

	self.visible = true
	self.type = control_type.control
	self.align_x = 0
	self.align_y = 0
    self.align_scale = 1
	self.align={}
	self.align[1] = align_x1
	self.align[2] = align_y1
	self.tween_list = {}
	return self
end
function control:update(dt)
	if not table.empty(self.tween_list) then
		if self.tween_list[1].tween:update(dt) then
			local func = self.tween_list[1].func
			if func ~= nil and type(func) == "function" then
				func(self)
			end
			table.remove( self.tween_list, 1 )
		end
		self:align_control()
	end
	for i,v in ipairs(self.children or {}) do
		v:update(dt)
	end
end
function control:print()
    
end
function control:draw()
	if self.visible == false then
		return
	end
	-- 子控件
	if UI.auxiliary then
		lg.rectangle("line",self.x,self.y,self.w,self.h)
	end
	for i,v in ipairs(self.children or {}) do
		v:draw()        
	end
end

--返回false就是找到了，不继续；返回true就是没找到，继续
function control:event_process( event,x, y, button, istouch, presses ,tab )
	if self.visible and math.pointinrect( x,y,self.x,self.y,self.w,self.h ) then
		local count = #(self.children or {})
		for i=count,1,-1 do
			local v = self.children[i]
			if v:event_process( event,x, y, button, istouch, presses ,tab ) == false then
				-- 子控件找到了，不继续了
				return false
			end
		end
		if self.touch ~= nil then
			-- 自己找到了
			table.insert( tab, self)
            -- 增加缓动效果
            if event == event_type.down then
                if self.tween_scale == true then
                    self:tween(0.05, {align_scale = 1.2})
                    self:tween(0.05, {align_scale = 1})
                end
            end
			--! touch_continue属性指影响自己，不影响自己的子控件
			if self.touch_continue == true then
				-- 自己的属性是继续touch就继续查找
				return true
			else
				-- 自己的属性不是继续touch，就不继续了
				return false
			end
		else
			return true
		end
	else
		-- 范围外，继续
		return true
	end
end

function control:align_control( )
	if self.align == nil or table.empty(self.align) then
		return
	end
	self.align[1](self)
	self.align[2](self)
	
	if UI.auxiliary then
		lg.rectangle("line",self.x,self.y,self.w,self.h)
	end
	for i,v in ipairs(self.children or {}) do
		v:align_control( )
	end
end
function control:set_align( value )
	local t = value:split1({','})
	if #t ~= 2 then 
		error("align error "..(ctrl.name or "").." "..value)
		return
	end
	if align_func[t[1]] == nil then
		error("align error "..(ctrl.name or "").." "..value)
		return
	end
	if align_func[t[2]] == nil then
		error("align error "..(ctrl.name or "").." "..value)
		return
	end
	
	self.align={}
	self.align[1] = align_func[t[1]]
	self.align[2] = align_func[t[2]]
    -- 延迟执行
    self:tween(0.5, {})
end

function control:find_child( path )
	if path == "" or path == nil then
		return
	end
	local t = path:split('/')
	local p = self
	for i,v in ipairs(t) do
		local find = false
		for j,ctrl in ipairs(p.children or {}) do
			if ctrl.name == v then
				p = ctrl
				find = true
				break
			end
		end
		if find == false then
			return nil
		end
	end
	return p
end

function control:add_child(ctrl)
	if ctrl == nil then return end
	table.insert(self.children,ctrl)
    ctrl.parent = self
end

-- 根据字符串创建子控件
function control:add_child_str(xml_string)
	local xmldata = xml_parser:parser(xml_string)
	if xmldata == nil then
		error("xml parser fail")
	end
	local ctrl = create_control(xmldata:children()[1],self)
	self:align_control( )
	return ctrl
end

function control:remove_child()		
	for i,v in ipairs(self.children or {}) do
		v:remove_child()
		v = {}			
	end
	self.children = {}
end
function control:child_count()
	return #(self.children or {})
end
----------------------------------------
-- 外部函数

-----------------
--动画
function control:tween(duration,target,easing,func)
	local tween = tween.new(duration,self,target,easing)
	table.insert( self.tween_list,  {tween = tween,func = func} )
end
--取消动画
function control:clear_tween()
	self.tween_list = {}
end
-----------------

--可见性
function control:set_visible( visible )
	self.visible = visible
end

--设置名字
function control:set_name( name )
	self.name = tostring(name)
end

--设置响应函数
function control:set_touch( func_str )
	local t = func_str:split('.')
	if #t ~= 2 then
		error("touch func error "..(self.name or ""))
		return
	end
	local module = UI.script[t[1]]
	if module == nil then
		error("touch func error module "..func_str)
		return
	end
	local func = module[t[2]]
	if func == nil then
		error("touch func error,can't find func. ctrl name:<"..(self.name or "").."> func:<"..t[2]..">")
		return
	end
	self.touch = func
end

-- 打印控件
function control:print(tab_count)
    local tab = ""
    tab_count = tab_count or 0
    for i=1,tab_count do
        tab = tab.."    "
    end
    print(tab.."<"..get_control_type_name(self.type).." name:"..(self.name or "").." x:"..(self.x or "").." y:"..(self.y or "").." w:"..(self.w or "").." h:"..(self.h or "").." visible:"..tostring(self.visible)..">")
    for i,v in ipairs(self.children or {}) do
        v:print(tab_count+1)
    end
end
----------------------------------------------------------------

----------------------------------------------------------------
--panel
local panel = {}
setmetatable(panel, control)
panel. __index = panel
function panel.new()
	local self = {}
	self = control.new()
	setmetatable(self, panel)
	
	self.type = control_type.panel
	self.align_type = align_type.align_type_stretch
	return self
end

----------------------------------------------------------------

----------------------------------------------------------------
-- scrollviewer
local scrollviewer = {}
setmetatable(scrollviewer, control)
scrollviewer. __index = scrollviewer

local scroll_type = 
{
	horizontal = 1,
	vertical = 2,
}
function scrollviewer.new()
	local self = {}
	self = control.new()
	setmetatable(self, scrollviewer)
	
	self.type = control_type.scrollviewer
	self.scroll_type = scroll_type.vertical

    self.touched = false
	
    ---------------------
    -- 单次点击偏移量
    self.ori_x = 0    
	self.ori_y = 0 
	self.step_x = 0
	self.step_y = 0
    ---------------------
    -- 累计偏移量
    self.move_x = 0 
    self.move_y = 0
    ---------------------
	return self
end

function scrollviewer:draw()
	if self.visible == false then
		return
	end
	-- 子控件
	if UI.auxiliary then
		lg.rectangle("line",self.x,self.y,self.w,self.h)
	end
    -- 设置剪刀
	lg.setScissor(self.x,self.y,self.w+1,self.h+1)

	lg.push()   -- stores the coordinate system
	lg.translate(self.move_x + self.step_x,self.move_y + self.step_y)
	for i,v in ipairs(self.children or {}) do
		v:draw()
	end
	lg.pop()   -- return to our scaled coordinate state.
	lg.setScissor()
end

function scrollviewer:event_process( event,x, y, button, istouch, presses ,tab )
	if self.visible and math.pointinrect( x,y,self.x,self.y,self.w,self.h ) then
		if event == event_type.down then
            self.touched = true
			self.ori_x = x
			self.ori_y = y
            UI.priority_ctrl = self
		end
	end
	if event == event_type.up then
        self.touched = false
		self.ori_x = 0
		self.ori_y = 0
        -- 把本次点击的累计到累计累积偏移量中
        self.move_x = self.move_x + self.step_x
        self.move_y = self.move_y + self.step_y
		self.step_x = 0
		self.step_y = 0

		if self.scroll_type == scroll_type.vertical then
            -- 如果子控件是文本，获取他的实际总高度
            local all_height = 0
            for i,v in ipairs(self.children or {}) do
                if v.all_height then
                    all_height = v.all_height
                    break
                end
            end
            
            if self.move_y > 0 then
			    self:tween(0.5, {move_y = 0})
            elseif self.move_y < 0 and (all_height <= self.h) then
			    self:tween(0.5, {move_y = 0})
            elseif self.move_y < 0 and (all_height > self.h) and self.move_y < -(all_height - self.h)  then
			    self:tween(0.5, {move_y = -(all_height - self.h)})
            end
		elseif self.scroll_type == scroll_type.horizontal then
            if self.move_x > 0 then
			    self:tween(0.5, {move_x = 0})
            end
		end
        
        UI.priority_ctrl = nil

	elseif event == event_type.move then
        if self.touched then
            -- 计算本次偏移量
            if self.scroll_type == scroll_type.vertical then
                self.step_y = (y - self.ori_y)*1.5
            elseif self.scroll_type == scroll_type.horizontal then
                self.step_x = (x - self.ori_x)*1.5
            end
        end
	end
	
	local count = #(self.children or {})
	for i=count,1,-1 do
		local v = self.children[i]
		if v:event_process( event,x, y, button, istouch, presses ,tab ) == false then
			-- 子控件找到了，不继续了
			return false
		end
	end
    -- 只有它确定不处理了，才继续
    return self.touched == false
    
end

function scrollviewer:scroll_default()
    self.move_x = 0
    self.step_x = 0
    self.move_y = 0
    self.step_y = 0
    
end
----------------------------------------------------------------

----------------------------------------------------------------
-- image
local image = {}
setmetatable(image, control)
image. __index = image
function image.new()
	local self = {}
	self = control.new()
	setmetatable(self, image)

	self.type = control_type.image
	self.align_type = align_type.align_type_stretch
	self.img_color = {1,1,1,1}
    self.img_fill = image_fill_type.image_fill_type_stretch
	return self
end
function image:draw()
	if self.visible == false then
		return
	end
	if UI.auxiliary then
		lg.rectangle("line",self.x,self.y,self.w,self.h)
	end
    -- 设置剪刀
    -- lg.setScissor(self.x,self.y,self.w+2,self.h+2)
    
	if self.img and UI.enable_draw then
        -- 获取原来默认颜色
        local r,g,b,a = lg.getColor()
        lg.setColor(self.img_color)
        
		if self.img_slice then
			-- 1_1  1_2  1_3
			-- 2_1  2_2  2_3
			-- 3_1  3_2  3_3
			if self.img_slice_scale == nil then
				local x_scale = self.w / (self.img_slice[1]+self.img_slice[3])
				local y_scale = self.h / (self.img_slice[2]+self.img_slice[4])
				if x_scale < y_scale then
					self.img_slice_scale = x_scale
				else
					self.img_slice_scale = y_scale
				end
				if self.img_slice_scale > 1 then
					self.img_slice_scale = 1
				end
			end
			
			lg.draw(self.img,self.img_1_1,(self.x),(self.y),0,self.img_slice_scale,self.img_slice_scale)
						
			local w = self.w-(self.img_slice[1]+self.img_slice[3])*self.img_slice_scale
			if w > 0 then
				local viewx, viewy, vieww, viewh = self.img_1_2:getViewport( )
				lg.draw(self.img,self.img_1_2,(self.x+(self.img_slice[1]*self.img_slice_scale)),(self.y),0,w/vieww,self.img_slice_scale)
			end
			
			lg.draw(self.img,self.img_1_3,(self.x+self.w-(self.img_slice[3]*self.img_slice_scale)),(self.y),0,self.img_slice_scale,self.img_slice_scale)
			
			local h = self.h-((self.img_slice[2]+self.img_slice[4])*self.img_slice_scale)
			if h > 0 then
				local viewx, viewy, vieww, viewh = self.img_2_1:getViewport( )
				lg.draw(self.img,self.img_2_1,(self.x),(self.y+(self.img_slice[2]*self.img_slice_scale)),0,self.img_slice_scale,h/viewh)
			end
			
			local w = self.w-((self.img_slice[1]+self.img_slice[3])*self.img_slice_scale)
			local h = self.h-((self.img_slice[2]+self.img_slice[4])*self.img_slice_scale)
			if w >0 and h>0 then
				local viewx, viewy, vieww, viewh = self.img_2_2:getViewport( )
				lg.draw(self.img,self.img_2_2,(self.x+(self.img_slice[1]*self.img_slice_scale)),(self.y+(self.img_slice[2]*self.img_slice_scale)),0,w/vieww,h/viewh)
			end

			local h = self.h-((self.img_slice[2]+self.img_slice[4])*self.img_slice_scale)
			if h > 0 then
				local viewx, viewy, vieww, viewh = self.img_2_3:getViewport( )
				lg.draw(self.img,self.img_2_3,(self.x+self.w-self.img_slice[3]*self.img_slice_scale),(self.y+self.img_slice[2]*self.img_slice_scale),0,self.img_slice_scale,h/viewh)
			end

			lg.draw(self.img,self.img_3_1,(self.x),(self.y+self.h-(self.img_slice[4]*self.img_slice_scale)),0,self.img_slice_scale,self.img_slice_scale)
			
			local w = self.w-((self.img_slice[1]+self.img_slice[3])*self.img_slice_scale)
			if w > 0 then
				local viewx, viewy, vieww, viewh = self.img_3_2:getViewport( )
				lg.draw(self.img,self.img_3_2,(self.x+(self.img_slice[1]*self.img_slice_scale)),(self.y+self.h-(self.img_slice[4]*self.img_slice_scale)),0,w/vieww,self.img_slice_scale)
			end

			lg.draw(self.img,self.img_3_3,(self.x+self.w-(self.img_slice[3]*self.img_slice_scale)),(self.y+self.h-(self.img_slice[4]*self.img_slice_scale)),0,self.img_slice_scale,self.img_slice_scale)
			
		else
            self.factor_x = self.w/self.img_width
            self.factor_y = self.h/self.img_height
            if self.img_fill == image_fill_type.image_fill_type_scale then
                self.factor = self.factor_x
                if self.factor_x > self.factor_y then
                    self.factor = self.factor_y
                    self.ox = (self.img_width - self.w/self.factor)/2
                    self.oy = 0
                else
                    self.ox = 0
                    self.oy = (self.img_height - self.h/self.factor)/2
                end
                lg.draw(self.img,self.x,self.y,0,self.factor,self.factor,self.ox,self.oy)
            else
                lg.draw(self.img,self.x,self.y,0,self.factor_x,self.factor_y)
            end
		end
        -- 恢复默认颜色
        lg.setColor(r,g,b,a)	
	end

	-- 子控件
	for i,v in ipairs(self.children or {}) do
		v:draw()
	end
    
    -- lg.setScissor()
    
end
function image:update_image()
	if self.img ~= nil then
        if self.img_slice ~= nil then
            local w = self.img:getWidth()
            local h = self.img:getHeight()
            local ws,hs = self.img:getDimensions()
            local n1 = self.img_slice[1]
            local n2 = self.img_slice[2]
            local n3 = self.img_slice[3]
            local n4 = self.img_slice[4]
    
            self.img_1_1 = lg.newQuad(0,		0,		n1,			n2,			ws,hs)
            self.img_1_2 = lg.newQuad(n1,		0,		w-n1-n3,	n2,			ws,hs)
            self.img_1_3 = lg.newQuad(w-n3,		0,		n3,			n2,			ws,hs)
            self.img_2_1 = lg.newQuad(0,		n2,		n1,			h-n2-n4,	ws,hs)
            self.img_2_2 = lg.newQuad(n1,		n2,		w-n1-n3,	h-n2-n4,	ws,hs)
            self.img_2_3 = lg.newQuad(w-n3,		n2,		n3,			h-n2-n4,	ws,hs)
            self.img_3_1 = lg.newQuad(0,		h-n4,	n1,			n4,			ws,hs)
            self.img_3_2 = lg.newQuad(n1,		h-n4,	w-n1-n3,	n4,			ws,hs)
            self.img_3_3 = lg.newQuad(w-n3,		h-n4,	n3,			n4,			ws,hs)
        end
	end
end
function image:set_image(_path)
    if _path:find("..") then
        -- 路径简化，处理相对路径，考虑多次../情况
        local function path_simplify(path)
            local t = path:split('/')
            local t1 = {}
            for i,v in ipairs(t) do
                if v == ".." then
                    table.remove(t1)
                else
                    table.insert(t1,v)
                end
            end
            return table.concat(t1,'/')
        end
        _path = path_simplify(UI.root_path.._path)
    else
        _path = UI.root_path.._path
    end
    if self.img_path == _path then
        return
    end
    self.img_path = _path

	if self.img ~= nil then
		self.img:release()
		if _path == "" then
			self.img = nil
			return
		end
	end
	self.img = lg.newImage(self.img_path)
	self.img_width = self.img:getWidth()
	self.img_height = self.img:getHeight()

	self:update_image()
end
function image:set_image_color(_color)
    if _color:find(",") then
        local t = _color:split(',')
        self.img_color = {tonumber(t[1])/255,tonumber(t[2])/255,tonumber(t[3])/255,tonumber(t[4])/255}
    else
        local t = {math.op_rshift(math.op_and(_color , 0xFF000000) , 24)/255 , math.op_rshift(math.op_and(_color , 0xFF0000), 16)/255 , math.op_rshift(math.op_and(_color , 0xFF00), 8)/255 , math.op_and(_color , 0xFF)/255 } 
        self.img_color = t
    end
end
function image:set_image_slice(value)		
	local t = value:split(',')
	if #t ~= 4 then 
		error("image_slice error "..(ctrl.name or "").." "..value)
		return
	end
	
	self.img_slice={}
	self.img_slice[1] = tonumber(t[1])
	self.img_slice[2] = tonumber(t[2])
	self.img_slice[3] = tonumber(t[3])
	self.img_slice[4] = tonumber(t[4])
	self:update_image()
end
function image:set_image_fill(value)
	if value == "scale" then
		self.img_fill = image_fill_type.image_fill_type_scale
	elseif value == "stretch" then
		self.img_fill = image_fill_type.image_fill_type_stretch
	end
end
----------------------------------------------------------------

----------------------------------------------------------------
-- label
local label = {}
setmetatable(label, control)
label. __index = label

function label.new()
	local self = {}
	self = control.new()
	setmetatable(self, label)

	self.type = control_type.label
	self.align_type = align_type.align_type_stretch

    --------------------------
    -- 更新标记
	self.text_update = true
    --------------------------
    -- 更新直接相关内容
    self.text_font = 1
	self.text_size = nil
    self.text = nil
	self.text_color = {1,1,1,1}
	self.text_update_table = {}

    -- 计算获取
    self.font = nil

    self.all_width = 0
    self.all_height = 0
    --------------------------

	self.text_align = {}
	self.text_align[1] = 3
	self.text_align[2] = 3
	return self
end
function label:draw()
	if self.visible == false then
		return
	end
	if UI.auxiliary then
		lg.rectangle("line",self.x,self.y,self.w,self.h)
	end

    -- 文本不自身设计剪刀了
    -- 设置剪刀
    -- lg.setScissor(self.x,self.y,self.w+1,self.h+1)

	if self.text then
		local font = self.font
		if font == nil then
			return
		end
		lg.setFont(font)
		
		if self.text_update then
			self.text_update_table = {}
            local n_tab = string.split1(self.text,{"\n"})
            for _,nv in ipairs(n_tab or {self.text}) do
                local text_length = font:getWidth( nv ) or 0
                if text_length > self.w then
                    local s_tab = string.split1(nv,{" "})
                    local str = ""
                    if #s_tab > 1 then
                        for i,v in ipairs(s_tab) do
                            local _str = str..v.." "
                            if font:getWidth( _str ) > self.w then
                                table.insert( self.text_update_table, {str=str,width=font:getWidth( str )})
                                str = v.." "
                            else
                                str = _str
                            end
                        end
                        table.insert( self.text_update_table, {str=str,width=font:getWidth( str )})
                    else
                        table.insert( self.text_update_table, {str=nv,width=font:getWidth( self.text )})
                    end
                else
                    table.insert( self.text_update_table, {str=nv,width=font:getWidth( self.text )})
                end
            end

            local text_update_table_size = #self.text_update_table            
            for i,v in ipairs(self.text_update_table) do
                
                if self.text_align[1] == text_align_type.text_align_type_x1 then
                    v.x = self.x
                elseif self.text_align[1] == text_align_type.text_align_type_x2 then
                    v.x = self.x+self.w-v.width
                else
                    v.x = self.x+(self.w-v.width)/2
                end
                -- 计算最大宽度
                if self.all_width < v.width then
                    self.all_width = v.width
                end
                
                if self.text_align[2] == text_align_type.text_align_type_y1 then
                    v.y = self.y+(i-1)*font:getHeight()
                elseif self.text_align[2] == text_align_type.text_align_type_y2 then
                    v.y = self.y+self.h-text_update_table_size*font:getHeight()+(i-1)*font:getHeight()
                else
                    v.y = self.y+(self.h-(text_update_table_size*font:getHeight()))/2+(i-1)*font:getHeight()
                end
            end
            -- 计算最大高度
            self.all_height = text_update_table_size*font:getHeight()
            
			self.text_update = false
		end
		for i,v in ipairs(self.text_update_table) do
            lg.print({self.text_color,v.str},v.x,v.y )
		end
	end

	-- 子控件
	for i,v in ipairs(self.children or {}) do
		v:draw()
	end

    -- lg.setScissor()
end
function label:align_control()
	if self.align == nil or table.empty(self.align) then
		return
	end
	self.align[1](self)
	self.align[2](self)
	
	if UI.auxiliary then
		lg.rectangle("line",self.x,self.y,self.w,self.h)
	end
	for i,v in ipairs(self.children or {}) do
		v:align_control( )
	end
	self:update_text()
end

function label:update_text()
	if self.text ~= nil and self.text_size ~= nil and self.text_font ~= nil then
		self.font = self:get_font()
		if self.font == nil then
            return		
		end
		self.text_update = true
	end
end
function label:get_text()
    return self.text
end
function label:set_text(_text)
	self.text = tostring(_text)
	self:update_text()
end
function label:set_text_size(_text_size)
	self.text_size = tonumber(_text_size)
	self:update_text()	
end
function label:set_text_font(_text_font)
	self.text_font = tonumber(_text_font)
	self:update_text()	
end

function label:get_font()
    if self.text_size ~= nil and self.text_font ~= nil and type(self.text_size) == "number" and type(self.text_font) == "number" then
        if UI.font_file[self.text_font] == nil then
            return nil
        end
        if UI.font[self.text_font] == nil then
            UI.font[self.text_font] = {}
        end
        local font = nil
        if UI.font[self.text_font][self.text_size] == nil then
            font = lg.newFont(UI.font_file[self.text_font], self.text_size * UI.default_scale)
            UI.font[self.text_font][self.text_size] = font
        else
            font  = UI.font[self.text_font][self.text_size]
        end
        return font
    end
end
--------------------------------

function label:set_text_color( _color )
	local t = {math.op_rshift(math.op_and(_color , 0xFF000000) , 24)/255 , math.op_rshift(math.op_and(_color , 0xFF0000), 16)/255 , math.op_rshift(math.op_and(_color , 0xFF00), 8)/255 , math.op_and(_color , 0xFF)/255 } 
	self.text_color = t
end
----------------------------------------------------------------

----------------------------------------------------------------
-- animation
local animation = {}
setmetatable(animation, control)
animation. __index = animation

function animation.new()
	local self = {}
	self = control.new()
	setmetatable(self, animation)

	self.type = control_type.animation
	self.align_type = align_type.align_type_stretch
	self.animation_path = ""
	self.animation = nil
	return self
end
function animation:draw()
	if self.visible == false then
		return
	end    
	if UI.auxiliary then
		lg.rectangle("line",self.x,self.y,self.w,self.h)
	end
    -- 设置剪刀
    lg.setScissor(self.x,self.y,self.w+1,self.h+1)
    
	if self.animation then
		local w = self.animation:getWidth()
		local h = self.animation:getHeight()
		self.animation:draw(self.x,self.y,0,self.w/w,self.h/h)
	end

	-- 子控件
	for i,v in ipairs(self.children or {}) do
		v:draw()
	end
    
    lg.setScissor()
    
end
function animation:update(dt)
	if self.animation and self.visible then
		self.animation:update(dt)
	end
	for i,v in ipairs(self.children or {}) do
		v:update(dt)
	end
end
function animation:update_animation( )
	if self.animation == nil then
		return
	end
	if self.visible then
		self.animation:play()
	else
		self.animation:pause()
	end
end
function animation:set_visible(visible)
	self.visible = visible
	self:update_animation()
end
function animation:set_animation_path(_path, tag, loop)
	if type(_path) == "string" and _path:length() > 0 then
		self.animation_path = UI.root_path .. _path
        -- animation_path文件所在的目录就是动画的根目录,
        local image_path = self.animation_path:match("(.*[/\\])")
		self.animation = peachy.new(self.animation_path, tag, loop,image_path)
		self:update_animation()
	end
end
----------------------------------------------------------------


-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- parse props and create control

local function parse_name( ctrl ,value )
	ctrl.name = value
end
local function parse_visible( ctrl , value )
	if value == "false" then
		ctrl:set_visible(false)
	elseif value == "true" then
		ctrl:set_visible(true)
	end
end
local function parse_area( ctrl ,value )
	if value == "" or type(value) ~= "string" then return end 
	local t = value:split1({','})

	ctrl.align_x = tonumber(t[1])
	ctrl.align_y = tonumber(t[2])
	ctrl.align_w = tonumber(t[3])
	ctrl.align_h = tonumber(t[4])
end
local function parse_tween_scale( ctrl, value )
	if value == "false" then
		ctrl.tween_scale = false
	elseif value == "true" then
		ctrl.tween_scale = true
	end
end
local function parse_image( ctrl, value )
	ctrl:set_image(value)
end
local function parse_image_color( ctrl, value )
	ctrl:set_image_color(value)
end

local function parse_image_slice( ctrl , value )
	ctrl:set_image_slice(value)
end
local function parse_image_fill(ctrl, value)
    ctrl:set_image_fill(value)
end

local function parse_text( ctrl, value )
	if value:startwith("@") then
		value = (text:get(value:slice(2)))
	end
	ctrl.text = value
	ctrl:update_text()
end

local function parse_text_size( ctrl, value )
    ctrl:set_text_size(value)
	ctrl:update_text()
end
local function parse_text_font( ctrl, value )
    ctrl:set_text_font(value)
	ctrl:update_text()
end

local function parse_text_color( ctrl, value )
	--RGBA
	-- local t = value:split1({','})
	-- if #t ~= 4 then 
	-- 	error("text text_color error "..(ctrl.name or "").." "..value)
	-- 	return
	-- end
	-- local t = {t[1],t[2],t[3],t[4]}
	ctrl:set_text_color(tonumber(value))
end

local function parse_animation_path( ctrl, value )
	ctrl:set_animation_path(value)
end
local text_align_value = 
{
	x1 = text_align_type.text_align_type_x1,
	x2 = text_align_type.text_align_type_x2,
	xx = text_align_type.text_align_type_xx,
	y1 = text_align_type.text_align_type_y1,
	y2 = text_align_type.text_align_type_y2,
	yy = text_align_type.text_align_type_yy,
}
local function parse_text_align( ctrl, value )
	local t = value:split1({','})
	if #t ~= 2 then 
		error("text align error "..(ctrl.name or "").." "..value)
		return
	end
	
	ctrl.text_align[1] = text_align_value[t[1]]
	ctrl.text_align[2] = text_align_value[t[2]]
end

local function parse_scroll_type( ctrl, value )
	if ctrl.type ~= control_type.scrollviewer then
		return
	end
	if value == "horizontal" then
		ctrl.scroll_type = scroll_type.horizontal
	elseif value == "vertical" then
		ctrl.scroll_type = scroll_type.vertical
	end
		
end

----------------------------------------------------------------
-- align

function align_x1( ctrl )
	if ctrl.align_type == nil then
		ctrl.align_type = ctrl.parent.align_type
	end
	local scale = UI.default_horizontal_scale
	if ctrl.align_type == align_type.align_type_scale then
		scale = UI.default_scale
	end
	if ctrl.align_w == nil then 
		ctrl.w = ctrl.parent.w
	else
		ctrl.w = ctrl.align_w * scale
	end
	ctrl.x = ctrl.parent.x + ctrl.align_x * scale 
    ctrl.x = ctrl.x - ctrl.w*(ctrl.align_scale-1)/2
    ctrl.w = ctrl.w * ctrl.align_scale
end
function align_x2( ctrl )	
	if ctrl.align_type == nil then
		ctrl.align_type = ctrl.parent.align_type
	end
	local scale = UI.default_horizontal_scale
	if ctrl.align_type == align_type.align_type_scale then
		scale = UI.default_scale
	end
	if ctrl.align_w == nil then 
		ctrl.w = ctrl.parent.w
	else
		ctrl.w = ctrl.align_w * scale
	end	
	ctrl.x = ctrl.parent.x + ctrl.parent.w - ctrl.w - ctrl.align_x * scale 
    ctrl.x = ctrl.x - ctrl.w*(ctrl.align_scale-1)/2
    ctrl.w = ctrl.w * ctrl.align_scale	
end
function align_xx( ctrl )	
	if ctrl.align_type == nil then
		ctrl.align_type = ctrl.parent.align_type
	end
	local scale = UI.default_horizontal_scale
	if ctrl.align_type == align_type.align_type_scale then
		scale = UI.default_scale
	end
	if ctrl.align_w == nil then 
		ctrl.w = ctrl.parent.w
	else
		ctrl.w = ctrl.align_w * scale
	end
	ctrl.x = ctrl.parent.x + (ctrl.parent.w - ctrl.w)/2 + ctrl.align_x * scale 
    ctrl.x = ctrl.x - ctrl.w*(ctrl.align_scale-1)/2
    ctrl.w = ctrl.w * ctrl.align_scale
end
function align_y1( ctrl )
	if ctrl.align_type == nil then
		ctrl.align_type = ctrl.parent.align_type
	end		
	local scale = UI.default_vertical_scale
	if ctrl.align_type == align_type.align_type_scale then
		scale = UI.default_scale
	end
	if ctrl.align_h == nil then 
		ctrl.h = ctrl.parent.h
	else
		ctrl.h = ctrl.align_h * scale
	end
	ctrl.y = ctrl.parent.y + ctrl.align_y * scale 
    ctrl.y = ctrl.y - ctrl.h*(ctrl.align_scale-1)/2
    ctrl.h = ctrl.h * ctrl.align_scale
end
function align_y2( ctrl )	
	if ctrl.align_type == nil then
		ctrl.align_type = ctrl.parent.align_type
	end		
	local scale = UI.default_vertical_scale
	if ctrl.align_type == align_type.align_type_scale then
		scale = UI.default_scale
	end
	if ctrl.align_h == nil then 
		ctrl.h = ctrl.parent.h
	else
		ctrl.h = ctrl.align_h * scale
	end
	ctrl.y = ctrl.parent.y + ctrl.parent.h - ctrl.h - ctrl.align_y * scale 
    ctrl.y = ctrl.y - ctrl.h*(ctrl.align_scale-1)/2
    ctrl.h = ctrl.h * ctrl.align_scale
end
function align_yy( ctrl )	
	if ctrl.align_type == nil then
		ctrl.align_type = ctrl.parent.align_type
	end	
	local scale = UI.default_vertical_scale
	if ctrl.align_type == align_type.align_type_scale then
		scale = UI.default_scale
	end
	if ctrl.align_h == nil then 
		ctrl.h = ctrl.parent.h
	else
		ctrl.h = ctrl.align_h * scale
	end
	ctrl.y = ctrl.parent.y + (ctrl.parent.h - ctrl.h)/2 + ctrl.align_y * scale 
    ctrl.y = ctrl.y - ctrl.h*(ctrl.align_scale-1)/2
    ctrl.h = ctrl.h * ctrl.align_scale
end
----------------------------------------------------------------
-- align_func实际定义
align_func = 
{
	x1 = align_x1,
	x2 = align_x2,
	xx = align_xx,
	y1 = align_y1,
	y2 = align_y2,
	yy = align_yy,
}
local function parse_align( ctrl ,value )
	ctrl:set_align(value)
end
----------------------------------------------------------------

local function parse_align_type( ctrl , value )
	if value == "scale" then
		ctrl.align_type = align_type.align_type_scale
	elseif value == "stretch" then
		ctrl.align_type = align_type.align_type_stretch
	end		
end

local function parse_touch(ctrl , value )
    if value == "" then
        ctrl.touch = nil
        return
    end
	local t = value:split('.')
	if #t ~= 2 then
		error("touch func error "..(ctrl.name or ""))
		return
	end
	local module = UI.script[t[1]]
	if module == nil then
		error("touch func error module "..value)
		return
	end
	local func = module[t[2]]
	if func == nil then
		error("touch func error,can't find func. ctrl name:<"..(ctrl.name or "").."> func:<"..t[2]..">")
		return
	end
	ctrl.touch = func
end
local function parse_touch_continue(ctrl , value )
	if value == "true" then
		ctrl.touch_continue = true
	end
end
local function parse_import(ctrl , value )
	local uidata = love.filesystem.read(UI.root_path .. value)	
	local xmldata = xml_parser:parser(uidata)
	if xmldata == nil then
		error("xml parser fail")
	end
	local c = ctrl.parent
	-- 因为这个控件已经创建过一次了，需要替换为import里的控件，重新创建一次。
	UI.remove_control(ctrl)
	ctrl = create_control(xmldata:children()[1],c)
end

-- 前置定义parse_props，为了parse_ref使用
local function parse_props(ctrl,node)
end

local function parse_ref(ctrl , value)
	local ref = UI.ref[value]
	if ref == nil then
		error("ref error "..(ctrl.name or "").." "..value)
		return
	end
	-- 根据ref创建控件属性
	parse_props(ctrl,ref)
	--深度继续子控件
	for i,v in ipairs(ref:children()) do
		create_control(v,ctrl)
	end
end
----------------------------------------------------------------
-- prop
local prop_value=
{
	name				=	parse_name,
	visible				=	parse_visible,
	area				=	parse_area,
	align				=	parse_align,
	align_type			=	parse_align_type,
	image_slice			=	parse_image_slice,
	image				=	parse_image,
	image_color			=	parse_image_color,
	image_fill			=	parse_image_fill,
	text				=	parse_text,
	text_size			=	parse_text_size,
	text_font			=	parse_text_font,
	text_align			= 	parse_text_align,
	scroll_type			=	parse_scroll_type,
	text_color			=	parse_text_color,
	animation_path	 	= 	parse_animation_path,
	touch				=	parse_touch,
	touchcontinue		=	parse_touch_continue,
	import				=	parse_import,
	ref					=	parse_ref,
    tween_scale         =   parse_tween_scale,
}

-- 实际定义parse_props
parse_props = function(ctrl,node)
    -- 先执行ref属性    
	for i,v in ipairs(node:props()) do
        local f_name=v["name"]
        if f_name == "ref" then
            local f_func=prop_value[f_name]
            if f_func then
                local f_value=v["value"]
                f_func(ctrl,f_value)
                break
            else
                error("no prop_value parse function "..f_name)
            end
        end
    end
    -- 再执行其他属性,可能覆盖ref属性
	for i,v in ipairs(node:props()) do
        local f_name=v["name"]
        if f_name ~= "ref" then
            local f_func=prop_value[f_name]
            if f_func then
                local f_value=v["value"]
                f_func(ctrl,f_value)
            else
                error("no prop_value parse function "..f_name)
            end
        end
    end
end

----------------------------------------------------------------

----------------------------------------------------------------
-- create control
local name_ctrl=
{
	panel = panel.new,
	scrollviewer = scrollviewer.new,
	label = label.new,
	image = image.new,
	animation = animation.new
}

local function create_node(node)
	local f = name_ctrl[node:name()]
	if f then
		local c = f()
		return c
	else
		error(node:name().."is no create node function")
		return nil 
	end
end

-- create_control
function create_control(xmlnode,parent)
    --先检查父控件下有没有同名控件，没有则正常创建，有则修改
    local _ctrl = nil 
    if parent then
		if parent.children == nil then 
			parent.children = {}
        else
            -- 先遍历xmlnode里有没有name
            for i,v in ipairs(xmlnode:props()) do
                local f_name=v["name"]
                if f_name == "name" then
                    local f_value=v["value"]
                    -- 遍历children里有没有同名
                    for i,v in ipairs(parent.children or {}) do
                        if v.name == f_value then
                            _ctrl = v
                            break
                        end
                    end
                    if _ctrl then
                        break
                    end
                end
            end
		end
    end
    if not _ctrl then
        -- 这是没有同名的情况（一般情况），就创建出控件,并设置父控件
        _ctrl = create_node(xmlnode)
        --如果还是空的，就不对了
        if _ctrl == nil then 
            error("create_node nil")
            return
        end
        --再设置父控件和子控件
        _ctrl.parent = parent
        if parent then
            if parent.children == nil then 
                parent.children = {}
            end
            table.insert(parent.children,_ctrl)
        end
    end
	--填充属性，（或者覆盖属性）
	parse_props(_ctrl,xmlnode)
	--深度继续子控件
	for i,v in ipairs(xmlnode:children()) do
        -- 递归创建子控件之前，先检查xmlnode的子控件有没有同名控件，有则报错，没有则正常创建
        if _ctrl.children then
            for i,v in ipairs(v:props()) do
                local f_name=v["name"]
                if f_name == "name" then
                    local f_value=v["value"]
                    for i,v in ipairs(_ctrl.children or {}) do
                        if v.name == f_value then
                            error("create_control repeat name:".._ctrl.name.."/"..f_value)
                            break
                        end
                    end
                end
            end
        end
		create_control(v,_ctrl)
	end
	return _ctrl
end


-- 因为parse_import用到了，所以放在前边
function UI.remove_control(ctrl)
	local parent = ctrl.parent
	if parent then
		for i,v in ipairs(parent.children) do
			if v == ctrl then
				table.remove(parent.children,i)
				break
			end
		end
	end
	ctrl = nil
end

-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- 模块外部调用
function UI.get_left( ... )
    local x, y, w, h = love.window.getSafeArea( )
    return x
end
function UI.get_right( ... )
    local x, y, w, h = love.window.getSafeArea( )
    return x+w
end
function UI.get_top( ... )
    local x, y, w, h = love.window.getSafeArea( )
    return y
end
function UI.get_bottom( ... )
    local x, y, w, h = love.window.getSafeArea( )
    return y+h
end
function UI.get_width( ... )
    local x, y, w, h = love.window.getSafeArea( )
    return w
end
function UI.get_height( ... )
    local x, y, w, h = love.window.getSafeArea( )
    return h
end
-- 工具函数，复制控件
function UI.duplicate_control(ctrl,new_parent_ctrl)
    if ctrl == nil or new_parent_ctrl == nil then
        return nil
    end
    local _ctrl = {}
    for k, v in pairs(ctrl) do
        if k ~= "parent" and k ~= "children" then
            if type(v) == "table" then
                if _ctrl[k]==nil then
                    _ctrl[k] = {}
                end
                table.copy(_ctrl[k], v)
            else
                _ctrl[k] = v
            end
        end
    end
    setmetatable(_ctrl, getmetatable(ctrl))
    _ctrl.parent = new_parent_ctrl
    if new_parent_ctrl.children == nil then
        new_parent_ctrl.children = {}
    end
    table.insert(new_parent_ctrl.children,_ctrl)
    -- 深度继续子控件
    for i, v in ipairs(ctrl.children or {}) do
        UI.duplicate_control(v,_ctrl)
    end
    return _ctrl
end
----------------------------------------------------------------
-- 按照顺序执行以下初始化
-- 0、设置初始化路径
function UI.init(root_path)
	UI.root_path = root_path
end
-- 1、设置宽高
function UI.set_window( w,h )
	UI.default_window_width = w
	UI.default_window_height = h
	UI.default_horizontal_scale = UI.get_width() / UI.default_window_width
	UI.default_vertical_scale = UI.get_height() / UI.default_window_height
	if UI.default_horizontal_scale < UI.default_vertical_scale then
		UI.default_scale = UI.default_horizontal_scale
	else
		UI.default_scale = UI.default_vertical_scale
	end
end
-- 2、设置字体
function UI.load_font( font_xml )
    UI.font_file = {}
    UI.font = {}
	local _data = love.filesystem.read(UI.root_path .. font_xml)
	if _data == nil then
		error("font_xml data fail")
	end
	local xmldata = xml_parser:parser(_data)
	if xmldata == nil then
		error("font_xml parser fail")
	end
	local xmlnode = xmldata:children()[1]
	for i,node in ipairs(xmlnode:children()) do
		local index = ""
		local file = ""
		for j,v in ipairs(node:props()) do
			local name = v["name"]
			local value = v["value"]
			if name == "name" then
				index = tonumber(value) or 0
			elseif name == "file" then
				file = value
			end
		end
        if UI.font_file[index] ~= nil then
            error("font_xml index repeat:"..index)
        end
        UI.font_file[index] = UI.root_path .. file
	end
end
-- 3、设置脚本
function UI.load_script(script_xml)
    if UI.script == nil then
        UI.script = {}
        setmetatable(UI.script,{__index = _G})
    end
	local script_data = love.filesystem.read(UI.root_path .. script_xml)
	if script_data == nil then
		error("script_xml data fail")
	end
	local xmldata = xml_parser:parser(script_data)
	if xmldata == nil then
		error("script_xml parser fail")
	end
	local xmlnode = xmldata:children()[1]
	for i,node in ipairs(xmlnode:children()) do
		local module = ""
		local file = ""
		for j,v in ipairs(node:props()) do
			local name = v["name"]
			local value = v["value"]
			if name == "module" then
				module = value
			elseif name == "file" then
				file = value
			end
		end

		if module == "" or file == "" then
			error("script module fail:"..module.." "..file)
		end
		local file_data = love.filesystem.read(UI.root_path .. file)	
				
		local _env = {} 
		setmetatable(_env, {__index = UI.script})
		local f,e = load(file_data,module,"t",_env)
		if f == nil then
			error("script module fail,module:["..module.."],file:["..file.."]\nERROR:["..e.."]")
		else
			f()
		end
		UI.script[module] = _env
		
	end
end
-- 4、设置引用
function UI.load_ref(ref_xml)
	UI.ref={}
	local ref_data = love.filesystem.read(UI.root_path .. ref_xml)
	if ref_data == nil then
		error("ref_xml data fail")
	end
	local xmldata = xml_parser:parser(ref_data)
	if xmldata == nil then
		error("ref_xml parser fail")
	end
	local xmlnode = xmldata:children()[1]
	for i,node in ipairs(xmlnode:children()) do
		local name = node:name() 
		UI.ref[name] = node
	end
end
-- 最后加载界面
function UI.load_ui(root_xml)	
	local uidata = love.filesystem.read(UI.root_path .. root_xml)	
	local xmldata = xml_parser:parser(uidata)
	if xmldata == nil then
		error("xml parser fail")
	end
	UI.root = create_control(xmldata:children()[1],nil)
	if UI.root == nil then 
		error("create UI root fail")
		return
	end
	
	local root_parent = control.new()
	root_parent.x = UI.get_left()
	root_parent.y = UI.get_top()
	root_parent.w = UI.get_width()
	root_parent.h = UI.get_height()
    print("Safe area:",root_parent.x,root_parent.y,root_parent.w,root_parent.h)
	root_parent.align_type = align_type.align_type_stretch

	UI.root.parent = root_parent

	UI.root:align_control()
end


----------------------------------------------------------------

function UI.update(dt)
	UI.root:update(dt)
end

function UI.draw()
	UI.root:draw()
end

function UI.event_process( event,x, y, button, istouch, presses  )
	local tab = {}
	if UI.lock_event_process then
		return false
	end
    if UI.priority_ctrl then
        UI.priority_ctrl:event_process( event,x, y, button, istouch, presses ,tab )
    else
        UI.root:event_process( event,x, y, button, istouch, presses ,tab )
    end

	for i,v in ipairs(tab or {}) do
		v.touch(event,x,y,v)
	end
    if #tab > 0 then
        return true
    else
        return false
    end
end

-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

function UI.textedited(text, start, length)
    -- for IME input
end

function UI.textinput(t)
end

function UI.keypressed(key, scancode, isrepeat )
	-- print("UI keypressed")
end

-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- 辅助函数
-- 设置是否渲染
UI.enable_draw = true
function UI.set_enable_draw( flag )
	UI.enable_draw = flag
end
-- 设置是否渲染辅助线
UI.auxiliary = false
function UI.set_draw_auxiliary(flag)
	UI.auxiliary = flag
end
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

return UI;