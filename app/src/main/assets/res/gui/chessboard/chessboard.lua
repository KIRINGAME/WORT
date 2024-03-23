
local chessboard = require("src/chessboard")



----------------------------------------------------------------
-- 逻辑相关

function setPoint( point )
    if point == nil then 
        point = 0
    end
    GET_UIROOT():find_child("chessboard_root/top/point_main/point"):set_text(point)
end

local tmp_id = 0
function refresh_dict(shift_id)
    local dict_record = chessboard.dict_record
    if table.count(dict_record) <= 0 then return end
    if shift_id == nil then
        tmp_id = table.count(dict_record)
    else
        tmp_id = tmp_id + tonumber(shift_id)
    end
    if tmp_id > table.count(dict_record) then
        tmp_id = table.count(dict_record)
    elseif tmp_id < 1 then
        tmp_id = 1
    end
    local word = dict_record[tmp_id]
    local dict_word = dict.dict_word[word] or ""
    local word_str = string.lower(word).."\n"..dict_word.."\n"
    -- for k,v in ipairs(tab_dict_word) do
    --     word_str = word_str .. v.t .."  ".. v.d.."\n"
    -- end
    local list = GET_UIROOT():find_child("chessboard_root/dict_win/dict_win_bg/list/sv/word_list")
    list:set_text(word_str)
    GET_UIROOT():find_child("chessboard_root/dict_win/dict_win_bg/list/sv"):scroll_default()
    GET_UIROOT():find_child("chessboard_root/dict_win/dict_win_bg/word"):set_text(string.upper(word))
    GET_UIROOT():find_child("chessboard_root/dict_win/dict_win_bg/count"):set_text(tmp_id.."/"..table.count(dict_record))
end


----------------------------------------------------------------
-- UI相关

function on_touch_back( event, x, y, ctrl )
    if event == event_type.down then
        sound.play("click")
        if chessboard.startgame_type == "stage" then
            GET_UI().CallBackStageFunc()
        elseif chessboard.startgame_type == "day" then
            GET_UI().CallBackFunc()
        end
        GET_UIROOT():find_child("chessboard_root/dict_win"):set_visible(false)
    end
end

function on_touch_dict( event, x, y, ctrl )
    if event == event_type.down then
        sound.play("click")
	    gui.script.chessboard.refresh_dict()
        if table.count(chessboard.dict_record or {}) > 0 then
            GET_UIROOT():find_child("chessboard_root/dict_win"):set_visible(true)
        end
        
    end
end
function on_touch_hint( event, x, y, ctrl )
    if event == event_type.down then
        sound.play("hint")
        chessboard.Tip()
    end
end
--------------------------------
-- (*ads*)激励广告
local callback_count = 1
function rewardedAdCallBack( ... )
    timer.add_timer(1,function ()
        if game.show_rewarded_finished() then
            callback_count = 1
            chessboard.setPoint(chessboard.PointCount + 100)
            return
        end
        if callback_count < 10 then
            rewardedAdCallBack()
        else
            callback_count = 1
        end
    end)
end
--------------------------------
function on_touch_coin_msgbox( event, x, y, ctrl )
    if event == event_type.down then
        sound.play("click")
        if game.is_rewarded_loaded() then
            GET_UIROOT():find_child("chessboard_root/msgbox_win"):set_visible(true)
        end
    end    
end
function on_touch_coin( event, x, y, ctrl )
    if event == event_type.down then
        sound.play("click")
        -- (*ads*)激励广告
        GET_UIROOT():find_child("chessboard_root/msgbox_win"):set_visible(false)
        -- print("game:",_G,_G.game)
        if game.show_rewarded() then
            rewardedAdCallBack()
        end
    end
end
function on_touch_shuffle( event, x, y, ctrl )
    if event == event_type.down then
        sound.play("click")
        chessboard.shuffle_revolver()
    end
end

function on_touch_dict_win( event, x, y, ctrl )
    if event == event_type.down then
        GET_UIROOT():find_child("chessboard_root/dict_win"):set_visible(false)
    end
end
function on_touch_dict_back( event, x, y, ctrl )
    if event == event_type.down then
	    gui.script.chessboard.refresh_dict(-1)
    end
end
function on_touch_dict_front( event, x, y, ctrl )
    if event == event_type.down then
	    gui.script.chessboard.refresh_dict(1)
    end
end


function on_touch_msgbox( event, x, y, ctrl )
    if event == event_type.down then
        ctrl:set_visible(false)
    end
end

function on_touch_blank( event, x, y, ctrl )
end



