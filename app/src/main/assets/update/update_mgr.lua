-- TODO: set_global_cb 参数支持...

local UI = require ("lib/UI")
local update_lib = require ("lib/update")
local update_mgr = setmetatable({}, UI)

-- 是否更新完毕
update_mgr.updating = false

local CDN_URL = "humpback.one"
-- local CDN_URL = "192.168.6.22"
local MAX_TIME_OUT_COUNT = 3

function update_mgr.get_file(ver,file,md5)
    -- 下载file
    print("update_mgr.get_file",ver,file,md5)
    local function update_file(file_name , status , per)
        GET_UPDATE_UIROOT():find_child("main/txt"):set_text("update "..file_name.." "..string.format("%.2f%%", per*100))
        if per >= 1 then
            if status == 'closed' then
                -- 检查单个md5
                local _data = util.readfile(file)
                local _md5 = love.data.encode("string", "hex", love.data.hash('md5',(_data)))
                if _md5 ~= md5 then
                    -- 文件md5不一致
                    -- 再下载一次
                    update_mgr.get_file(ver,file,md5)
                end
            end
        end
    end
    update_lib.get(CDN_URL, "/update/"..ver.."/", file , update_file)
end


function update_mgr.get_file_list(ver)
    -- 下载file_list
    print("update_mgr.get_file_list",ver)
    -- 全部下载完毕之后
    local function update_all_file( param )
        -- 检查全部md5
        local ver = param.ver
        local list =param.list
        local match = true
        for i, v in ipairs(list) do
            local _data = util.readfile(v.file)
            local _md5 = love.data.encode("string", "hex", love.data.hash('md5',(_data)))
            if _md5 ~= v.md5 then
                match = false
                break
            end
        end
        if match then
            util.savefile("cache/local_ver.txt",ver)
        end
        update_lib.set_global_cb(nil)
        -- 再次触发版本检查
        update_mgr.get_ver(0)
    end
    -- 下载file_list内的所有文件
    local function update_file_list(file_name , status , per)
        -- GET_UPDATE_UIROOT():find_child("main/txt"):set_text("update "..file_name.." "..string.format("%.2f%%", per*100))
        if per >= 1 then
            local file_list,size = util.readfile("cache/"..ver.."_file_list.txt")
            local list = {}
            for file,md5 in (string.gmatch(file_list or "",[[(%g+) (%g+)]])) do
                table.insert(list,{file = file,md5 = md5})
                -- 判断本地已有数据
                local need_update = true
                local _data = util.readfile(file)
                if _data then
                    local _md5 = love.data.encode("string", "hex", love.data.hash('md5',(_data)))
                    if _md5 == md5 then
                        need_update = false
                    end
                end
                if need_update then
                    -- 不一致的才下载，一致的就不下载了，断文件续传
                    update_mgr.get_file(ver,file,md5)
                end
            end
            update_lib.set_global_cb(update_all_file,{ver=ver,list=list})
        end
    end
    update_lib.get(CDN_URL, "/update/"..ver.."/", "cache/"..ver.."_file_list.txt",update_file_list)
end
function update_mgr.get_ver(time_out_count)
    -- 下载ver_list
    print("update_mgr.get_ver",time_out_count)
    -- time_out_count作为递归的超时计数参数进行传递

    local local_ver,size = util.readfile("cache/local_ver.txt")
    local function update_ver(file_name , status , per)
        -- GET_UPDATE_UIROOT():find_child("main/txt"):set_text("update "..file_name.." "..string.format("%.2f%%", per*100))
        if status == "closed" then
            if per >= 1 then
                local ver,size = util.readfile("cache/ver_list.txt")
                local target_ver = nil
                for i in (string.gmatch(ver or "",[[(%g+)]])) do
                    if local_ver == i then
                        break
                    else
                        target_ver = i
                    end
                end
                if target_ver == nil then
                    -- 已经是最新的版本了 
                    update_mgr.updating = false
                else
                    -- 有版本差距，更新吧
                    update_mgr.get_file_list(target_ver)
                end
            end
        elseif status == "timeout" then
            time_out_count = time_out_count + 1
            if time_out_count >= MAX_TIME_OUT_COUNT then
                -- 跳过更新了
                update_mgr.updating = false
            else
                update_mgr.get_ver(time_out_count)
            end
        else
            print("ERROR:",status)
        end
    end
    
    update_lib.get(CDN_URL, "/update/", "cache/ver_list.txt",update_ver)
    update_lib.set_global_cb(nil)
end
function update_mgr.init()
    -- update_mgr.updating = true
    update_mgr.updating = false

	UI.set_window(540,960)
	UI.init("update/")
	UI.load_ui("update_ui.xml",{[1]="res/gui/font/font.ttf"})
    
    -- 超时计数初始化
    -- update_mgr.get_ver(0)
end

function update_mgr.tick(dt)
    -- update是否还在tick
    if update_mgr.updating then
        update_lib.tick()
        return true
    else
        return false
    end
end

function update_mgr.draw()
    if update_mgr.updating then
        UI.draw()
    
        -- local osString = love.system.getOS( )
        -- if osString == "Android" or osString == "iOS" then
        -- else
        --     local fps = love.timer.getFPS()
        --     love.graphics.setColor(1, 0, 0)
        --     love.graphics.print('FPS: ' .. love.timer.getFPS(), 0, 0)
        --     love.graphics.print('Memory: ' .. math.floor(collectgarbage 'count') .. ' kb', 0, 16)
        --     love.graphics.setColor(1, 1, 1)
        -- end
        return true
    else
        return false
    end
end

function update_mgr.event_process( event,x, y, button, istouch, presses  )
    if update_mgr.updating then
        if UI.event_process( event,x, y, button, istouch, presses  ) then
            return 
        end
    end
end

function update_mgr.is_updateing()
    return update_mgr.updating
end
---------------------------------------
--外部调用接口
-------------------------------------------------------------------------------------------------

function GET_UPDATE_UI()
	return update_mgr
end
function GET_UPDATE_UIROOT()
	return update_mgr.root
end
return update_mgr