
local dict = require("lib/dict")
local background = require("src/background")
local chessboard = require("src/chessboard")
local gui = require("src/gui")
require("res/text")
local mri = require("lib/MemoryReferenceInfo")
require("src/sound")
require("lib/util")
local admob = require("admob")
local game = {}
game.loaded = false
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
------------------------------------------------------


------------------------------------------------------
------------------------------------------------------
-- 购买VIP相关
local purchase_id = "one.humpback.wordt.vip"

-- 循环检查iap状态
local check_count = 0
local function check_iap()
    -- 安卓系统先不检查内购
	local osString = love.system.getOS( )
	if osString == "Android" then
		GET_UIROOT():find_child("login_root/main/remove"):set_visible(false)
		GET_UIROOT():find_child("chessboard_root/top/remove"):set_visible(false)
        return false
    end
	--已经确认购买过了
	if game.is_iap() then
		GET_UIROOT():find_child("login_root/main/remove"):set_visible(false)
		GET_UIROOT():find_child("chessboard_root/top/remove"):set_visible(false)
		return true
	end

	if osString ~= "Android" and osString ~= "iOS" then
		return true
	end

	local iap = love.system.hasPurchase(purchase_id)
	
	if iap == false then
		if check_count < 600 then
			check_count = check_count + 1
			timer.add_timer(2,check_iap)
		else
			check_count = 0
		end
	else
		
		GET_UIROOT():find_child("login_root/main/remove"):set_visible(false)
		GET_UIROOT():find_child("chessboard_root/top/remove"):set_visible(false)

		game.check_iap_purchased = true
		check_count = 0
	end

	return iap
end

-- 判断是否已经购买
function game.is_iap()
    game.check_iap_purchased = game.check_iap_purchased or false
	return game.check_iap_purchased
end
-- 发起购买请求
function game.make_iap()
	local osString = love.system.getOS( )
	if osString ~= "Android" and osString ~= "iOS" then
		return true
	end

	local iap = check_iap()
	if not iap then
		-- 发起支付
		love.system.makePurchase(purchase_id)
	end
	return iap
end

-- 恢复购买
function game.restore_iap()
	local osString = love.system.getOS( )
	if osString ~= "Android" and osString ~= "iOS" then
		return true
	end

	local iap = check_iap()
	if not iap then
        -- 恢复支付
		love.system.restorePurchases()
	end
end
------------------------------------------------------
------------------------------------------------------


------------------------------------------------------
------------------------------------------------------
-- 广告相关

------------------------------------------------------
-- 内部接口，装机前两天，不展示广告
local function ad_time_delay()
	-- local install_day = cfg.get("braintrainingline","install_day")
	-- if install_day == nil then
	-- 	local day = os.date("%j")
	-- 	cfg.set("braintrainingline","install_day",day)
	-- end
end
-- 内部接口，是否初始广告中
local function is_ad_time_delay()
    return false
	-- local install_day = cfg.get("braintrainingline","install_day")
	-- local day = os.date("%j")
	-- if install_day == nil then
	-- 	ad_time_delay()
	-- 	return true
	-- else
	-- 	if tonumber(install_day) < tonumber(day) then
	-- 		return false
	-- 	elseif tonumber(install_day) > tonumber(day) then
	-- 		cfg.set("braintrainingline","install_day",day)
	-- 	end
	-- end
	-- return true
end
------------------------------------------------------

------------------------------------------------------
-- 初始化间隔广告
function game.init_ads()
	-- depend on OS
	if admob then		
		-- admob.test("ac0bd8e96448531d2db42d74aea18a18")--测试
		admob.test("")
		
        -- 先检查是否购买了
        -- 购买了，就不广告
        if not check_iap() then
            -- admob.createBanner("ca-app-pub-3940256099942544/2934735716","bottom")--测试
            -- admob.createBanner("ca-app-pub-9869163784601757/1357067057","bottom")
            -- admob.hideBanner()
            
            -- admob.requestInterstitial("ca-app-pub-3940256099942544/1033173712")--测试
            admob.requestInterstitial("ca-app-pub-9869163784601757/6870028000")
            
        end

        -- 但是显示奖励广告
		-- admob.requestRewardedAd("ca-app-pub-3940256099942544/5224354917")--测试
		admob.requestRewardedAd("ca-app-pub-9869163784601757/2951798448")
	end
end
-- 显示横幅广告
function game.show_banner()
	-- 购买了，就不广告
	if game.is_iap() then
		return false
	end
	-- -- 装机前几天，不出广告
	if is_ad_time_delay() then
		return false
	end
    if admob then
        admob.showBanner()
        return true
    end
    return false
end
-- 隐藏横幅广告
function game.hide_banner()
	-- 购买了，就不广告
	if game.is_iap() then
		return false
	end
    if admob then
        admob.hideBanner()
        return true
    end
    return false
end
-- 播放间隔广告
function game.show_interstitial()
	-- 购买了，就不广告
	if game.is_iap() then
		return false
	end
	-- -- 装机前几天，不出广告
	if is_ad_time_delay() then
		return false
	end
	
	if admob then
		if admob.isInterstitialLoaded() then
			admob.showInterstitial()
            return true
		end
	end
    return false
end
-- 播放奖励广告
function game.show_rewarded()
	-- 购买了，就不广告
	-- if game.is_iap() then
	-- 	return false
	-- end
	-- -- 装机前几天，不出广告
	if is_ad_time_delay() then
		return false
	end
	
	if admob then
		if admob.isRewardedAdLoaded() then
			admob.showRewardedAd()
            return true
		end
	end
    return false
end
function game.is_rewarded_loaded()
	-- if game.is_iap() then
	-- 	return false
	-- end
	if admob then
		if admob.isRewardedAdLoaded() then
            return true
        end
    end
    return false
end
function game.show_rewarded_finished()
    if admob and admob.coreRewardedAdDidFinish() then
        return true
    end
    return false
end

function game.event(t)
    -- if admob then
    --     local str = table.tojson(t)
    -- end
end
------------------------------------------------------

------------------------------------------------------
------------------------------------------------------



------------------------------------------------------
------------------------------------------------------
-- 游戏逻辑相关
function game.load()	
	-- depend on OS

	-----------------------------------
	math.randomseed(os.time())
	-----------------------------------
    
	-----------------------------------
	-- 初始化语言设置
	text:set_cfg(2)
	-- if love.system.getLanguage ~= nil then
	-- 	local language_str = love.system.getLanguage() or ""
	-- 	if language_str:startwith("zh-Hans") then
	-- 		text:set_cfg(1)
	-- 	else
	-- 		text:set_cfg(2)
	-- 	end
	-- else
	-- end
	-----------------------------------
	local beg = os.clock()
	-----------------------------------	

	gui.init()
	gui.set_enable_draw(true)	
	gui.set_draw_auxiliary(false)
	

	-----------------------------------
    -- 尝试先展示loading界面
    timer.add_timer(0,function() 

        -----------------------------------
        -- 初始化音乐声音
        local music_stop = cfg.get("me_humpback_word_cfg","music")
        if music_stop == nil then
            cfg.set("me_humpback_word_cfg","music",false)
            music_stop = false
        end
        local sound_stop = cfg.get("me_humpback_word_cfg","sound")
        if sound_stop == nil then
            cfg.set("me_humpback_word_cfg","sound",false)
            sound_stop = false
        end

        sound.init()

        -- 是否暂停音乐
        if music_stop then
            sound.stop_music()
        else
            sound.play_music("music",0.3)
        end

        -- 是否暂停音效
        if sound_stop then
            sound.stop_sound()
        end
        
        
        background.load()
        background.set_enable_draw(true)
        -----------------------------------
        -- 字典相关**
        local dict_path = {
            {"res/data/deutsch3.txt",3},
            {"res/data/deutsch4.txt",4},
            {"res/data/deutsch5.txt",5},
            {"res/data/deutsch6.txt",6},
            {"res/data/deutsch7.txt",7},
            {"res/data/deutsch8.txt",8}
        
        }
        -- 首先初始化词典表
        dict.load_dict(dict_path)
    
        -----------------------------------
        -- 创建单词表，第一次才需要，运行时不需要
        -- dict.create_stage(dict_path)
        -- do return end
        -----------------------------------
        
        ----------------------------------- 
        dict.load_dict_word("res/data/word_list.txt")
        dict.load_stage("res/data/stage_list.txt")
    
        ------------------------------------------------------------------------------------------------
        -- 测试字典
        -- local file_data = util.readfile("res/data/Oxford English Dictionary.txt")
        -- if file_data == nil then return end

        -- local _dict = {}
        -- local _word = {}
        -- _word[3] = {}
        -- _word[4] = {}
        -- _word[5] = {}
        -- _word[6] = {}
        -- _word[7] = {}
        -- _word[8] = {}
        -- for w,t in string.gmatch(file_data,"(%a+)  ([%C]*)") do
        --     -- if w:find("%A") then
        --     --     print(w)
        --     -- end
        --     -- if w:find(" ") then
        --     --     print(w)
        --     -- end
        --     if w:utf8len()>=3 and w:utf8len()<=8 then
        --         w = string.upper(w)
        --         if table.containKey(_dict,w) then
        --             t = _dict[w].."\n"..t
        --         end
        --         _dict[w] = t
        --         if not table.containValue(_word[w:utf8len()],w) then
        --             table.insert(_word[w:utf8len()],w)
        --         end
        --     end
        --     -- print(w,t)
        --     -- c = c+1
        --     -- if c >=2 then
        --     --     break
        --     -- end
        -- end
        -- print(table.count(_dict))
        -- local dict_str = table.tojson(_dict)
        -- util.savefile("dict_oxrod.txt",dict_str)
        
        -- for k, v in pairs(_word) do
        --     local str = ""
        --     for i, _w in ipairs(v) do
        --         str = str .. _w.."\n"
        --     end
        --     print(k,#v)
        --     util.savefile("dict_"..k..".txt",str)
        -- end
        
        -- 重新初始化字典
        -- dict.dict_word = _dict
        
        -- local t = {}
        -- for i, v in ipairs(dict.stage) do
        --     local table_dict = dict.dict_word[v]
        --     if table_dict == nil and v:utf8len()<=7 then
        --         table.insert(t,v)
        --     end
        -- end
        -- print(table.count(t),table.count(dict.stage),table.count(t)/table.count(dict.stage))
        ------------------------------------------------------------------------------------------------

        -----------------------------------
        chessboard.load()
        chessboard.set_draw_auxiliary(true)

        GET_UIROOT():find_child("loading_root").visible = false
        GET_UIROOT():find_child("login_root").visible = true
        -----------------------------------
        
        gui.script.login.login_init()

        game.loaded = true
    end)

    -- 初始化广告
    game.init_ads()
	-----------------------------------
	local _end = os.clock()
	log("load time:".._end - beg)
	-----------------------------------
end

function game.update(dt)
    if not game.loaded then
        game.load()
    end
	chessboard.update(dt)
	gui.update(dt)
end

function game.draw()
	background.draw()
	chessboard.draw()
	gui.draw()
end

function game.event_process( event,x, y, button, istouch, presses  )
    if game.loaded then
        if gui.event_process( event,x, y, button, istouch, presses  ) then
            return 
        end
        if chessboard.event_process( event,x, y, button, istouch, presses  ) then 
            return 
        end
    end
end
function game.keypressed(key, scancode, isrepeat )
	gui.keypressed(key, scancode, isrepeat )
    print(key, scancode, isrepeat)
    screenshot.keypressed(key, scancode, isrepeat)
end
------------------------------------------------------
------------------------------------------------------


------------------------------------------------------
------------------------------------------------------
-- 内存检查想
function game.memory_info()
    -- PC版本才测试，手机版本不测试
	local osString = love.system.getOS( )
	if osString == "Android" and osString == "iOS" then
        return
	end
    if mri == nil then
        return
    end
    -- Setting the config not add time stamp at the end of the file name.
    mri.m_cConfig.m_bAllMemoryRefFileAddTime = false
    
    mri_count = mri_count or 0
    mri_count = mri_count + 1
    --如果是单数次，就before,双数次就after
    if mri_count%2 == 1 then
        -- Before dumping, collect garbage first.
        collectgarbage("collect")
        
        print("DumpMemorySnapshot 1-Before start")
        mri.m_cMethods.DumpMemorySnapshot("./", "1-Before", -1)
        print("DumpMemorySnapshot 1-Before end")
    else
        -- Dump memory snapshot again.
        collectgarbage("collect")
        print("DumpMemorySnapshot 2-After start")
        mri.m_cMethods.DumpMemorySnapshot("./", "2-After", -1)
        print("DumpMemorySnapshot 2-After end")

        print("DumpMemorySnapshotComparedFile start")
        mri.m_cMethods.DumpMemorySnapshotComparedFile("./", "Compared", -1, 
        "./LuaMemRefInfo-All-[1-Before].txt", 
        "./LuaMemRefInfo-All-[2-After].txt")
        print("DumpMemorySnapshotComparedFile end")
    end
end


------------------------------------------------------
------------------------------------------------------

-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
_G.game = game
return game;