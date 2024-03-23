
local background = require("src/background")
local chessboard = require("src/chessboard")

function init()
    local stage_id_unlock = chessboard.get_cfg("stage_id_unlock")
    if stage_id_unlock == nil then
        stage_id_unlock = 1
        chessboard.set_cfg("stage_id_unlock",stage_id_unlock)
    else
        stage_id_unlock = tonumber(stage_id_unlock)
    end
    local stage_list = dict.stage
    local stage_max = #stage_list
    if stage_id_unlock <= 0 then
        stage_id_unlock = 1
    end
    if stage_id_unlock > stage_max then 
        stage_id_unlock = stage_max
    end

    local parent = GET_UIROOT():find_child("stage_root/stage_con/stage_list")
    parent:remove_child()
    
    local f = math.floor((stage_id_unlock - 1)/5)   
    local stage_beg = (f-1)*5+1
    local stage_end = (f+1)*5+5
    if stage_beg < 0 then
        stage_beg = 0*5+1
        stage_end = (0+2)*5+5
    end
    if stage_end > stage_max then
        stage_beg = (math.floor((stage_max - 1)/5)-2)*5+1
        stage_end = stage_max
    end
    for i=stage_beg,stage_end do
        local x = math.fmod(i-1,5)*100-200 
        local y = (math.modf((i-stage_beg)/5))*100
        local str
        if stage_id_unlock > i then
            str = string.format([[
                        <image name="%d" align="xx,y1" area="%d,%d,80,80" image="img/btn_background.png" align_type="scale" image_slice="17,17,17,17" touch="stage.on_touch_sel_stage">
                            <image align="x2,y2" image="img/unlock.png" area="4,4,32,32" align_type="scale" />
                            <label align="xx,yy" text="%d" text_font="3" text_size="30" text_color="0x000000FF" align_type="scale" />
                        </image>
                        ]],i,x,y,i)
        elseif stage_id_unlock == i then
            str = string.format([[
                        <image name="%d" align="xx,y1" area="%d,%d,80,80" image="img/btn_background.png" align_type="scale" image_slice="17,17,17,17" touch="stage.on_touch_sel_stage">
                            <label align="xx,yy" text="%d" text_font="3" text_size="30" text_color="0x000000FF" align_type="scale" />
                        </image>
                        ]],i,x,y,i)
        else
            str = string.format([[
                        <image name="%d" align="xx,y1" area="%d,%d,80,80" image="img/bg_topic.png" align_type="scale" image_slice="17,17,17,17" touch="stage.on_touch_sel_stage">
                            <label align="xx,yy" text="%d" text_font="3" text_size="30" visible="false" align_type="scale" />
                            <image align="xx,yy" image="img/lock.png" area="0,0,20,32" align_type="scale" />
                        </image>
                        ]],i,x,y,i)
        end
        parent:add_child_str(str)
    end
end

function on_touch_back( event, x, y, ctrl )
    if event == event_type.down then
        sound.play("click")
        gui.CallBackFunc()
    end
end

function on_touch_sel_stage( event, x, y, ctrl )
    if event == event_type.down then
        sound.play("click")
        local id = tonumber(ctrl.name)
        
        local stage_id_unlock = chessboard.get_cfg("stage_id_unlock")
        stage_id_unlock = tonumber(stage_id_unlock)

        if id > stage_id_unlock then
            return
        end
        GET_UIROOT():find_child("chessboard_root"):set_visible(true)
        GET_UIROOT():find_child("stage_root"):set_visible(false)
        chessboard.stage_id = id
        GET_UI().CallStartFunc()
        
    end
end


-- local test = 0
-- local x = math.mod(test,5)*100
-- local y = (math.modf(test/5)+1)*100
-- test = test+1
-- local str = string.format([[
--             <image name="%d" align="x1,y1" area="%d,%d,80,80" image="img/bg_topic.png" align_type="scale" image_slice="17,17,17,17" touch="stage.on_touch_sel_stage">
--                 <label align="xx,yy" text="%d" text_font="1" text_size="36"/>
--             </image>
--             ]],test,x,y,test)
-- local parent = ctrl.parent.parent:find_child("stage_list")
-- local c = parent:add_child_str(str)