

local chess = require("src/chess")
local background = require("src/background")

local lg = love.graphics

local chessboard = {}
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
function chessboard.get_cfg(key)
	return cfg.get("deutscher_cfg",key)
end
function chessboard.set_cfg(key,value)
	cfg.set("deutscher_cfg",key,value)
end

-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- 随机刷新子弹
function chessboard.shuffle_revolver()
	local t = chessboard.revolver.bullet
	local size = #t
	for i = math.ceil(size/2) ,1,-1 do
		local index = math.random(math.ceil(size/2), size)
		local x ,y = t[i].x,t[i].y
		t[i].x = t[index].x
		t[i].y = t[index].y
		t[index].x = x
		t[index].y = y
	end
	for i,v in ipairs(t) do
		v:align(t.x,t.y)
	end
end
-- 添加子弹到左轮里
local function revolver_add_bullet()
	local size = chessboard.word:utf8len()
	local center_x = chessboard.revolver.center_x
	local center_y = chessboard.revolver.center_y
	local chess_size = chessboard.revolver.w/4
	local radius = chess_size+chess_size/4
	for i=1,size do
		local radian = math.pi*2*(i-1)/size
		local x = center_x + math.sin( radian )*radius - chess_size/2
		local y = center_y - math.cos( radian )*radius - chess_size/2
		
		local c = chess.new(x, y, chess_size, chessboard.word:utf8sub(i,i), "font/font.ttf", chess_size*0.7, "img/small_wheel.png",true,true,false)
		table.insert( chessboard.revolver.bullet,c)	
	end
	chessboard.shuffle_revolver()
end

-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- 子弹操作

	----------------------------------
-- 展示压入射击列表的子弹列表
local function show_revolver_shot()
	local text = ""
	for i,v in ipairs(chessboard.revolver.shot_bullet) do
		text = text..v.text
	end
	if text:length() > 0 then
		GET_UIROOT():find_child("chessboard_root/chessboard_ctrl/spell_bg"):set_visible(true)
		GET_UIROOT():find_child("chessboard_root/chessboard_ctrl/spell_bg/spell_word"):set_text(text)
		
		GET_UIROOT():align_control()
	else
		GET_UIROOT():find_child("chessboard_root/chessboard_ctrl/spell_bg"):set_visible(false)
	end
end

-- 如果这个棋子已经在列表的最后一位，那么就意味着删除它
-- 弹出射击子弹队列
local function pop_revolver_bullet(v)
	local t  = chessboard.revolver.shot_bullet
	local spell_len = #t
	if spell_len > 1 then
		if t[spell_len-1] == v then
			t[spell_len].bg_visible = false
			table.remove( t, spell_len )
		end
	end
	show_revolver_shot()
end

-- 压入子弹到射击队列
local function push_revolver_bullet(v)
	chessboard.revolver.shot_aim = true
	table.insert( chessboard.revolver.shot_bullet, v )
	local id = #chessboard.revolver.shot_bullet
	sound.play("click_letter_"..id)
	show_revolver_shot()
end

-- 发射射击队列里的子弹
local function revolver_bullet_shot()
	local _check_tab = chessboard.revolver.shot_bullet
	local check_word = ""
	for i,v in ipairs(_check_tab) do
		check_word = check_word..v.text
	end
	local findinlist = false
	for i,v in ipairs(chessboard.list_output_word) do
		if v == check_word then
			findinlist = true
			break
		end
	end
	if findinlist then 
		local findinboard = false
		for i,v in ipairs(chessboard.table_chessboard_wordlist) do
			if check_word == v.text then
				findinboard = true
				if v.visible==false then
					log("GOOD!"..check_word)
					for i,c in ipairs(v.list) do
						c.text_visible=true
					end
					v.visible=true
					-- 完成一个单词的奖励
					insert_dict_word(v.text)
				else
					log("ALREADY!"..check_word)
				end
				break
			end
		end
		if not findinboard then
			-- 附加数据里
			insert_dict_word(check_word)
		end
	end
	
	--
	for i,v in pairs(chessboard.revolver.bullet) do
		v.bg_visible = false
	end
	chessboard.revolver.shot_aim 	= false
	chessboard.revolver.shot_bullet	=	{}
	chessboard.revolver.shot_pos 	=	{}

	show_revolver_shot()
end
----------------------------------


local function get_table_chessboard(x,y)
	for i,v in ipairs(chessboard.table_chessboard) do
		if v.x == x and v.y == y then
			return v
		end
	end
	return nil
end

local function add_table_chessboard(t)
	-- local t = {x=x,y=y,across_down=not v.across_down,word=word}
	local size = 1
	if chessboard.table_chessboard == nil then chessboard.table_chessboard = {}	end 
	if chessboard.table_chessboard_wordlist == nil then chessboard.table_chessboard_wordlist = {}	end 
	local node = {text=t.word,list={},visible=false}
	if t.across_down then
		for i=1,t.word:utf8len() do
			local x = (t.x+i-1)*size
			local y = (t.y)*size
			local c = get_table_chessboard(x,y)
			if c == nil then 
				c = chess.new(x, y, size, t.word:utf8sub(i,i), "font/font.ttf", 1, "img/bg.png",false,false,true)
				table.insert(chessboard.table_chessboard,c)
			end
			table.insert(node.list,c)
		end
	else
		for i=1,t.word:utf8len() do
			local x = (t.x)*size
			local y = (t.y+i-1)*size
			local c = get_table_chessboard(x,y)
			if c == nil then 
				c = chess.new(x, y, size, t.word:utf8sub(i,i), "font/font.ttf", 1, "img/bg.png",false,false,true)
				table.insert(chessboard.table_chessboard,c)
			end
			table.insert(node.list,c)
		end
	end

	table.insert( chessboard.table_chessboard_wordlist ,node)
	log("list:",#(chessboard.table_chessboard_wordlist),t.word)
	return #(chessboard.table_chessboard_wordlist)
end

-- 这个算法很诡异，它借用了之前的渲染数据的结构（在排布之前，渲染结果里放置的实际是逻辑数据），重新排布为真正的渲染数据
local function align_board()
	local min_x,min_y = 10000,10000
	local max_x,max_y = -1,-1
	for i,v in ipairs(chessboard.table_chessboard) do
		if v.x < min_x then
			min_x = v.x
		end
		if v.y < min_y then
			min_y = v.y
		end
		if v.x > max_x then
			max_x = v.x
		end
		if v.y > max_y then
			max_y = v.y
		end
	end
	if chessboard.main == nil then
		chessboard.main = GET_UIROOT():find_child("chessboard_root/chessboard_main")
	end
	local chessboard_size_x = chessboard.main.w
	local chessboard_size_y = chessboard.main.h
	local scale_x = chessboard_size_x/(max_x-min_x + 2 )	--左右增加两格作为margin
	local scale_y = chessboard_size_y/(max_y-min_y + 2 )	--上下增加两格作为margin
	local scale_size
	if scale_x < scale_y then
		scale_size = scale_x
	else
		scale_size = scale_y
	end
	local chessboard_margin_x = chessboard.main.x + (chessboard.main.w - scale_size*(max_x-min_x + 1 ) )/2
	local chessboard_margin_y = chessboard.main.y + (chessboard.main.h - scale_size*(max_y-min_y + 1 ) )/2
	
	for i,v in ipairs(chessboard.table_chessboard) do
		local x = (v.x - min_x )*scale_size + chessboard_margin_x
		local y = (v.y - min_y )*scale_size + chessboard_margin_y
		v:align(x,y,scale_size,scale_size*0.8)
	end
end

local function setBanner()
    sound.play("win",0.1)
    
    local function OnEndTween( ctrl )
        GET_UIROOT():find_child("chessboard_root/banner"):set_visible(false)
    end
    GET_UIROOT():find_child("chessboard_root/banner"):set_visible(true)
    local lw = GET_UIROOT():find_child("chessboard_root/banner")
    lw.align_y = 600
    lw:tween(1,{align_y = 80},"outQuint",OnEndTween)
end
local function check_board()
	local chess_win = true
	for i,v in ipairs(chessboard.table_chessboard_wordlist) do
		if v.visible == false then
			chess_win = false
			break
		end
	end
	if chess_win then

		setBanner()
		if chessboard.startgame_type == "stage" then
			local stage_id_unlock = chessboard.get_cfg("stage_id_unlock")
			stage_id_unlock = tonumber(stage_id_unlock)
			if chessboard.stage_id >= stage_id_unlock then
				chessboard.set_cfg("stage_id_unlock",stage_id_unlock + 1)
				chessboard.setPoint(chessboard.PointCount + 10)
			end
			chessboard.stage_id = chessboard.stage_id + 1
            --(*ads*)插页广告
            if game.show_interstitial() then
                chessboard.setPoint(chessboard.PointCount + 50)
            end
			
		elseif chessboard.startgame_type == "day" then
			chessboard.day_index = chessboard.day_index + 1
			chessboard.set_cfg("day_index",chessboard.day_index)
			chessboard.day_word={}
			chessboard.set_cfg("day_word",chessboard.day_word)
			chessboard.setPoint(chessboard.PointCount + 10)
            --(*ads*)插页广告
            if game.show_interstitial() then
                chessboard.setPoint(chessboard.PointCount + 50)
            end
		end
		
		timer.add_timer(1,function ()
			background.reset()
			chessboard.init()
		end)
	end
end

-- 完成一个单词的相关逻辑处理
function insert_dict_word(word_text)
	reward_word_point(word_text)

	-- 尝试刷新，内部判断
	check_board()
end

-- 完成一个单词的奖励
function reward_word_point( word )
	local reward = false
    -- 记录关卡和每日
	if chessboard.startgame_type == "stage" then
		if chessboard.reward_list["s"..chessboard.stage_id] == nil then
			chessboard.reward_list["s"..chessboard.stage_id] = {}
		end
		local t = chessboard.reward_list["s"..chessboard.stage_id]
		if not table.containValue(t,word) then
			table.insert(t,word)	
			chessboard.set_cfg("reward_list",chessboard.reward_list)
            reward = true
		end
	elseif chessboard.startgame_type == "day" then
		-- 记录每日单词进度
        if not table.containValue(chessboard.day_word, word) then
            table.insert( chessboard.day_word, word )
            chessboard.set_cfg("day_word",chessboard.day_word)
            reward = true
        end
	end
    if reward then
        sound.play("get_word")
        chessboard.setPoint(chessboard.PointCount + 1)
    end
    
    -- 记录字典展示
    if not table.containValue(chessboard.dict_record,word) then
        table.insert( chessboard.dict_record, word )
    end
end
function chessboard.setPoint( point )
	sound.play("gold")
	chessboard.PointCount = point
	gui.script.chessboard.setPoint(point)
	chessboard.set_cfg("point",point)
end
function chessboard.getPoint()
	local point = chessboard.get_cfg("point")	
	if point == nil then
		point = 0
	end
	chessboard.PointCount = tonumber(point)
	gui.script.chessboard.setPoint(point)
end
function chessboard.Tip()
	if chessboard.PointCount <10  then
		gui.script.tips.show_tips(text:get(4))
		return 
	end

	local tip_text = ""
	for i,v in ipairs(chessboard.table_chessboard) do
		if v.text_visible == false then
			v.text_visible = true
			tip_text = v.text

			gui.script.tips.show_tips(text:get(5))
			chessboard.setPoint(chessboard.PointCount-10)
			
			break
		end
	end
	
	-- 判断一遍，有可能因此过关了
	for i,v in ipairs(chessboard.table_chessboard_wordlist) do
		if v.visible==false then
			local check_bytip = true
			for i,c in ipairs(v.list) do
				if c.text_visible==false then
					check_bytip = false
					break
				end
			end
			if check_bytip == true then
				v.visible = true
				insert_dict_word(v.text)
			end
		end
	end
end
function chessboard.get_day_word( )
	local now_jday = tonumber(os.date("%j"))
	local jday = tonumber(chessboard.get_cfg("day_j"))
	if jday ~= now_jday then
		chessboard.set_cfg("day_j",now_jday)
		chessboard.set_cfg("day_index",1)
		chessboard.day_word = {}
		chessboard.set_cfg("day_word",chessboard.day_word)
		local word_list = {}

		local dict_len_list = { 
			dict.word_len_min+1,
			dict.word_len_min+2,
			dict.word_len_min+3}		
		for i,v in ipairs(dict_len_list) do
			if v > dict.word_len_max then
				v = dict.word_len_max
			end
			local _word = dict.get_random_word(v)
            log("get_random_word:".._word)
			table.insert(word_list,_word)
		end
		
		chessboard.set_cfg("day_list",word_list)
	end
	local word_list = chessboard.get_cfg("day_list")
	local word_id = chessboard.get_cfg("day_index")
	chessboard.day_index = tonumber(word_id)
	if chessboard.day_index > 3 then
		gui.script.tips.show_tips(text:get(6),2)
		return nil
	end
	return word_list[word_id]
end
-------------------------------------------------------------------------------------------------
-- chessboard logic

function chessboard.init()
	-- 每回合初始化表

	-- 子弹初始化部分
	chessboard.revolver.bullet		=	{}																				-- 弹仓内子弹的table
	chessboard.revolver.shot_aim 	=	false																			-- 瞄准中，点击子弹拖动中
	chessboard.revolver.shot_bullet	=	{}																				-- 射击列表的子弹的table
	chessboard.revolver.shot_pos 	=	{}																				-- vector2d，点击射击的坐标

	chessboard.table_chessboard = {}			-- 全部牌面上的字母，以字母为单位
	chessboard.table_chessboard_wordlist = {}	-- 全部牌面上的单词组，以单词为单位


	

	-- -- 选出基准单词
	local word
	if chessboard.startgame_type == "stage" then
		local stage_list = dict.stage
		if chessboard.stage_id > #stage_list then
			return
		end
		word = stage_list[chessboard.stage_id]
	elseif chessboard.startgame_type == "day" then
		word = chessboard.get_day_word()
		if word == nil then
			gui.CallBackFunc()
			return
		end
	end
	
	chessboard.word = word

    log("***************",chessboard.word:utf8len())
    
	log(chessboard.word)
	
	chessboard.r = math.random(20,100)/100
	chessboard.g = math.random(20,100)/100
	chessboard.b = math.random(20,100)/100
	-- 设置转盘
	revolver_add_bullet()

	-- 根据基准单词找出所有的包含单词
	local list_output_word = dict.get_contain_word(word)
	chessboard.list_output_word = list_output_word
	-- table.print(chessboard.list_output_word)

	----------------------------------
	-- 生成牌面
	local grid = {}
	local grid_size = 50
	for i=1,grid_size do
		grid[i] = {}
		for j=1,grid_size do
			grid[i][j] = ""
		end
	end
	
	----------------------------------
	-- 缓存数组  要填入的单词  基准单词坐标 基准单词的方向（要填入的单词方向相反）
	local function get_letter_pos(letter,i_beg,j_beg)		
		if i_beg == nil and j_beg == nil then
			 i_beg = 1 
			 j_beg = 1
		else
			i_beg = i_beg + 1
			if i_beg > grid_size then 
				i_beg = 1 
				j_beg = j_beg + 1
				if j_beg >grid_size then
					return nil
				end
			end
		end

		for j=j_beg,grid_size do
			for i=i_beg,grid_size do
				if grid[i][j] == letter then
					return i,j,direction_up_down
				end
			end
		end
		return nil
	end
	local function set_grid(word)
		for i=1,word:utf8len() do
			local letter = word:utf8sub(i,i)
			local m,n
			repeat
				m,n = get_letter_pos(letter,m,n)
				if m~=nil and n~=nil then
					--找到字母了，判断有没有让人误解的格子
					local test = true
					------------------------------------------------------------------------------
					-- 先看横向
					-- 前边
					if m-(i-1)-1 >= 1 and grid[m-(i-1)-1][n] ~= "" then
						test = false
						goto next_1
					end
					-- 后边
					if m+(word:utf8len()-i)+1 <= grid_size and grid[m+(word:utf8len()-i)+1][n] ~= "" then
						test = false
						goto next_1
					end
					-- 中间和上下
					for s=1,word:utf8len() do
						local x = m-(i-1)+(s-1)
						local y = n
						if x<1 or x>grid_size then
							test = false
							goto next_1
							break
						end
						-- 中间
						if x~=m and grid[x][y] ~= "" then
							test = false
							goto next_1
							break
						end
						if x~=m and y-1>=1 and grid[x][y-1] ~= "" then 
							test = false
							goto next_1
							break
						end
						if x~=m and y+1>=1 and grid[x][y+1] ~= "" then 
							test = false
							goto next_1
							break
						end
					end
					if test then
						--找到合适位置						
						for s=1,word:utf8len() do
							local x = m-(i-1)+(s-1)
							local y = n
							grid[x][y] = word:utf8sub(s,s)
						end

						return true,m-(i-1),n,true
					end
					::next_1::
					------------------------------------------------------------------------------
					test = true
					-- 再看纵向
					-- 前边
					if n-(i-1)-1 >= 1 and grid[m][n-(i-1)-1] ~= "" then
						test = false
						goto next_2
					end
					-- 后边
					if n+(word:utf8len()-i)+1 <= grid_size and grid[m][n+(word:utf8len()-i)+1] ~= "" then
						test = false
						goto next_2
					end
					-- 中间和上下
					for s=1,word:utf8len() do
						local x = m
						local y = n-(i-1)+(s-1)
						if y<1 or y>grid_size then
							test = false
							goto next_2
							break
						end
						-- 中间
						if y~=n and grid[x][y] ~= "" then
							test = false
							goto next_2
							break
						end
						if y~=n and x-1>=1 and grid[x-1][y] ~= "" then 
							test = false
							goto next_2
							break
						end
						if y~=n and x+1>=1 and grid[x+1][y] ~= "" then 
							test = false
							goto next_2
							break
						end
					end
					if test then
						--找到合适位置						
						for s=1,word:utf8len() do
							local x = m
							local y = n-(i-1)+(s-1)
							grid[x][y] = word:utf8sub(s,s)
						end

						return true,m,n-(i-1),false
					end
					------------------------------------------------------------------------------
					-- 没有合适的位置，继续repeat找有没有别的位置
					::next_2::
				else
					--这个字母最终没找到合适的位置，下个字母
					break
				end
			until(false)
		end
		return false
	end
	----------------------------------
	
	-- 插入第一个单词
	local word = chessboard.list_output_word[1] or ""
	for s=1,word:utf8len() do
		grid[20+s-1][20] = word:utf8sub(s,s)
	end
	local t = {x=20,y=20,across_down=true,word=word}
	add_table_chessboard(t)

	-- 插入后续单词
	for i=2,#chessboard.list_output_word do
		local word = chessboard.list_output_word[i]
		
			local bool_set,x,y,across_down = set_grid(word)
			if bool_set == true then
				local t = {x=x,y=y,across_down=across_down,word=word}
				-- 真正插入表
				local count = add_table_chessboard(t)
				if count >= 10 then
					break
				end
			else
				log("add:"..word)
			end

	end
	----------------------------------
	-- 居中排布牌面
	align_board()
	----------------------------------

	for j=1,grid_size do
		local str = ""
		for i=1,grid_size do
			local w = grid[i][j]
			if w == "" then
				str = str .. "  "
			else
				str = str .. " " .. grid[i][j]
			end
		end
		log(j," "..str)
	end
	----------------------------------
    -- 收尾设置，棋盘初始化之后
	if chessboard.startgame_type == "stage" then
        local stage_id_unlock = chessboard.get_cfg("stage_id_unlock")
        stage_id_unlock = tonumber(stage_id_unlock)
        
        -- 只有当前关卡才显示，不然没意思了，没法重新玩了
        if stage_id_unlock == chessboard.stage_id then
            local stage_word = chessboard.reward_list["s"..chessboard.stage_id]
            if stage_word == nil then
                stage_word = {}
            end
    
            -- 显示已经认出的单词
            for k,v in pairs(stage_word or {}) do
                for m,n in ipairs(chessboard.table_chessboard_wordlist) do
                    if n.text == v then
                        n.visible = true
                        for _x,c in ipairs(n.list) do
                            c.text_visible = true
                        end
                        break
                    end
                end
            end
            -- 如果是新关卡，设置关卡的字典
            chessboard.dict_record = stage_word
        else
            -- 如果是老关卡，清理字典
            chessboard.dict_record = {}
        end
        

	elseif chessboard.startgame_type == "day" then
        
        --每日单词的存档记录
        local day_word = chessboard.get_cfg("day_word")
        if day_word == nil then
            day_word = {}
        end
        chessboard.day_word = day_word
        
        -- 如果是每日，就刷新每日的字典
        chessboard.dict_record = day_word

        -- 显示已经认出的单词
        for k,v in pairs(chessboard.day_word or {}) do
            for m,n in ipairs(chessboard.table_chessboard_wordlist) do
                if n.text == v then
                    n.visible = true
                    for _x,c in ipairs(n.list) do
                        c.text_visible = true
                    end
                    break
                end
            end
        end
	end
end

-------------------------------------------------------------------------------------------------
-- chessboard 通用接口

local ResPath = "res/"
function chessboard.load()

	---------------------------------------------------------------------------
	-- set callback func
	---------------------------------------------------------------------------
	gui.CallStartFunc = function()
		chessboard.startgame = true
		background.reset()
		chessboard.init()
		--(*ads*)显示横幅广告
		-- game.showBanner()
	end

	gui.CallBackStageFunc = function ( )
		chessboard.startgame = false
        gui.script.stage.init()
        background.reset()
        GET_UIROOT():find_child("chessboard_root"):set_visible(false)
		GET_UIROOT():find_child("stage_root"):set_visible(true)
		--(*ads*)隐藏横幅
        -- game.hideBanner()
	end

	gui.CallBackFunc = function()
		chessboard.startgame = false
		background.reset()
        GET_UIROOT():find_child("stage_root"):set_visible(false)
        GET_UIROOT():find_child("chessboard_root"):set_visible(false)
		GET_UIROOT():find_child("login_root"):set_visible(true)
		--(*ads*)隐藏横幅
        -- game.hideBanner()
	end

	chessboard.getPoint()
	local reward_list = chessboard.get_cfg("reward_list")
	if reward_list == nil then
		reward_list = {}
	end
	chessboard.reward_list = reward_list

	---------------------------------------------------------------------------
	-- load revolver
	---------------------------------------------------------------------------
	-- 以下永远是固定的
	chessboard.revolver = {}
	chessboard.revolver.ctrl 		=	GET_UIROOT():find_child("chessboard_root/chessboard_ctrl/chessboard_revolver")	-- 控件，用来计算位置
	chessboard.revolver.img 		=	lg.newImage(ResPath.."/gui/img/revolver.png")						-- 底图
	chessboard.revolver.x 			=	chessboard.revolver.ctrl.x														-- 控件的位置
	chessboard.revolver.y 			=	chessboard.revolver.ctrl.y														-- 控件的位置
	chessboard.revolver.w 			=	chessboard.revolver.ctrl.w														-- 控件的位置
	chessboard.revolver.h 			=	chessboard.revolver.ctrl.h														-- 控件的位置
	chessboard.revolver.center_x 	=	chessboard.revolver.ctrl.x + chessboard.revolver.ctrl.w/2						-- 控件的中心位置
	chessboard.revolver.center_y 	=	chessboard.revolver.ctrl.y + chessboard.revolver.ctrl.h/2						-- 控件的中心位置
	chessboard.revolver.sx			=	chessboard.revolver.w/chessboard.revolver.img:getWidth()						-- 底图的缩放比例
	chessboard.revolver.sy			=	chessboard.revolver.h/chessboard.revolver.img:getHeight()						-- 底图的缩放比例
	
	---------------------------------------------------------------------------

end

function chessboard.update(dt)
end

function chessboard.draw()
	
	if chessboard.startgame ~= true then return end 

	local lw = lg.getLineWidth()
	-- print(lw)
	lg.setLineWidth(10)
	local r,g,b,a = lg.getColor()

	-- revolver bg

	lg.setColor(1.0,1.0,1.0,0.5)
	lg.draw(chessboard.revolver.img, chessboard.revolver.x, chessboard.revolver.y, 0 , chessboard.revolver.sx, chessboard.revolver.sy)

	lg.setColor(chessboard.r,chessboard.g,chessboard.b,1.0)
	----------------------------------
	-- 设置连线
	local x,y = nil
	for i,v in ipairs(chessboard.revolver.shot_bullet) do
		if x == nil or y == nil then
			x = v.x + v.size/2
			y = v.y + v.size/2
		else
			local x_next = v.x + v.size/2
			local y_next = v.y + v.size/2
			lg.line(x,y,x_next,y_next)
			x = x_next
			y = y_next
		end
	end

	local size = #chessboard.revolver.shot_bullet
	if chessboard.revolver.shot_aim and size >= 1 then
		local v = chessboard.revolver.shot_bullet[size]
		lg.line(chessboard.revolver.shot_pos.x,chessboard.revolver.shot_pos.y,v.x + v.size/2,v.y + v.size/2)
	end
	
	----------------------------------

	-- chessboard
	for i,v in pairs(chessboard.table_chessboard) do
		v:draw(chessboard.r,chessboard.g,chessboard.b)
	end

	-- bullet
	for i,v in pairs(chessboard.revolver.bullet) do
		v:draw(chessboard.r,chessboard.g,chessboard.b)
	end


	lg.setColor(r,g,b,a)	
	lg.setLineWidth(lw)
end

function chessboard.event_process( event,x, y, button, istouch, presses  )
	if chessboard.startgame ~= true then return end 
	if event == event_type.down then
		for i,v in pairs(chessboard.revolver.bullet) do
			if v.touch and math.pointinrect(x,y,v.x+5,v.y+5,v.size-10,v.size-10) then
				if v.bg_visible == false then
					v.bg_visible = true
					-- 压入子弹，并且瞄准
					push_revolver_bullet(v)
					chessboard.revolver.shot_pos.x = x
					chessboard.revolver.shot_pos.y = y
				end
			end
		end
	elseif event == event_type.up then
		-- 射击
		revolver_bullet_shot()
	elseif event == event_type.move then
		if chessboard.revolver.shot_aim == true then
			for i,v in pairs(chessboard.revolver.bullet) do
				if v.touch and math.pointinrect(x,y,v.x+5,v.y+5,v.size-10,v.size-10) then
					if v.bg_visible  == false then
						v.bg_visible = true
						-- 压入子弹，并且瞄准
						push_revolver_bullet(v)
					else
						pop_revolver_bullet(v)
					end
				else
					--浮空的划线
					chessboard.revolver.shot_pos.x = x
					chessboard.revolver.shot_pos.y = y
				end
			end
		end
	end
end
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------
-- 辅助函数

function chessboard.set_draw_auxiliary( flag )
	chessboard.auxiliary = flag
end
return chessboard;