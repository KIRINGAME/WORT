
local e
function show_tips( txt , time)
    GET_UIROOT():find_child("tips_root/tips_bg/tips_txt"):set_text(txt)
    GET_UIROOT():find_child("tips_root"):set_visible(true)
    if e ~= nil then 
        e:stop()
    end
    time = time or 1
    e = timer.add_timer(time,function ()
        GET_UIROOT():find_child("tips_root"):set_visible(false)
    end)
    sound.play("tips")
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