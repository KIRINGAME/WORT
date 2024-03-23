
local background = require("src/background")
local chessboard = require("src/chessboard")


function on_touch_stage( event, x, y, ctrl )
    if event == event_type.down then
        sound.play("click")
        gui.script.stage.init()
        GET_UIROOT():find_child("login_root"):set_visible(false)
        GET_UIROOT():find_child("stage_root"):set_visible(true)
        background.reset()
        chessboard.startgame_type = "stage"
    end
end
function on_touch_day( event, x, y, ctrl )
    if event == event_type.down then
        sound.play("click")
        
        chessboard.startgame_type = "day"

        GET_UIROOT():find_child("login_root"):set_visible(false)
        GET_UIROOT():find_child("chessboard_root"):set_visible(true)
        GET_UI().CallStartFunc()

        --每日单词的存档记录
        local day_word = chessboard.get_cfg("day_word")
        if day_word == nil then
            day_word = {}
        end
        chessboard.day_word = day_word

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
-- 声音按钮
function on_touch_sound( event, x, y, ctrl )
    if event == event_type.down then
        sound.sound_stopped = not sound.sound_stopped 
        cfg.set("me_humpback_word_cfg","sound",sound.sound_stopped)
        login_init()
    end    
end
-- 音乐按钮
function on_touch_music( event, x, y, ctrl )
    if event == event_type.down then
        sound.music_stopped = not sound.music_stopped
        login_init()
        
        cfg.set("me_humpback_word_cfg","music",sound.music_stopped)

        if sound.music_stopped then
            sound.stop_music()
        else
            sound.play_music("music")
        end
    end    
end

--------------------------------------------------------------------
-- 打开iap界面
function on_touch_open_iap( event, x, y, ctrl )
    if event == event_type.down then
        sound.play("click")
        -- 展示购买界面
        GET_UIROOT():find_child("iap_root"):set_visible(true)
        
        local lw = GET_UIROOT():find_child("iap_root/main")
        lw.align_y = -350
        lw:tween(0.2,{align_y = 0})
        
        if game.is_iap() then
            GET_UIROOT():find_child("iap_root/main/remove_ads"):set_visible(false)
            GET_UIROOT():find_child("iap_root/main/restore_buy"):set_visible(true)
        else
            GET_UIROOT():find_child("iap_root/main/remove_ads"):set_visible(true)
            GET_UIROOT():find_child("iap_root/main/restore_buy"):set_visible(true)
        end
    end    
end
function on_touch_close( event, x, y, ctrl )
    if event == event_type.down then
        -- 关闭购买界面
        GET_UIROOT():find_child("iap_root"):set_visible(false)
    end
end
-- 购买VIP
function on_touch_remove_ads( event, x, y, ctrl )
    if event == event_type.down then
        sound.play("click")
        -- 购买VIP
        game.make_iap()
        GET_UIROOT():find_child("iap_root"):set_visible(false)
    end
end
-- 恢复购买
function on_touch_restore_buy( event, x, y, ctrl )
    if event == event_type.down then
        sound.play("click")
        -- 恢复购买
        game.restore_iap()
        GET_UIROOT():find_child("iap_root"):set_visible(false)
    end    
end
--------------------------------------------------------------------



--------------------------------------------------------------------
-- 内存检查
function on_touch_memory_info( event, x, y, ctrl )
    if event == event_type.down then
        game.memory_info()
    end
end
--------------------------------------------------------------------


function login_init()
    if sound.music_stopped then        
		GET_UIROOT():find_child("login_root/main/music"):set_image("img/btn_music_stop.png")
    else
		GET_UIROOT():find_child("login_root/main/music"):set_image("img/btn_music.png")
    end
    if sound.sound_stopped then        
		GET_UIROOT():find_child("login_root/main/sound"):set_image("img/btn_sound_stop.png")
    else
		GET_UIROOT():find_child("login_root/main/sound"):set_image("img/btn_sound.png")
    end
    local day = os.date("%d")
    local img = GET_UIROOT():find_child("login_root/main/day/img")
    img:set_image("img/calendar/icons8-calendar-"..day.."-60.png")
end