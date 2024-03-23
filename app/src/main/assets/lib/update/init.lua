local socket = require "socket"

local update = {}

-- 下载任务表
update.tasks = {}

-- 全部任务完成的回调函数
update.global_cb = {}

local function receive(connection)
    local s, status, partial = connection:receive(2^10)
    if status == "timeout" then
        coroutine.yield(connection)
    end
    return s or partial,status
end
local function get_task(file)
    for i, v in ipairs(update.tasks) do
        if v.file == file then
            return v
        end
    end
end

local function download(host, ver_path, file)
    local client_socket = socket.tcp()
    client_socket:settimeout(0.5)
    local _success, _status = client_socket:connect(host, 80)
    if _success ~= 1 then
        local t = get_task(file)
        if t then
            t.size = 0
            t.cb(file , _status , 0)
        end
        return
    end
    local request = string.format("GET %s Http/1.0\r\nhost: %s\r\n\r\n", ver_path..file, host)

    client_socket:send(request)
    local find = false
    while true do
        local s, status = receive(client_socket)
        -- 判断下载状态
        local _state = string.match(s,[[HTTP/1.1 %d+ (%g+)]])
        if _state~= nil and _state ~= "OK" then
            local t = get_task(file)
            if t then
                t.size = 0
                t.cb(file , "timeout" , 0)
            end
            break
        end
        -- 去掉文件头
        if not find then
            local pos = s:find("\r\n\r\n")
            if pos then
                -- 获取总长度
                local t = get_task(file)
                if t then
                    t.length = tonumber(string.match(s,[[Content%-Length: (%d+)]])) or 1
                end
                s = s:sub(pos+4)
                find = true
            else
                local pos = s:find("\n\n")
                if pos then
                    s = s:sub(pos+2)
                    find = true
                end
            end
        end
        
        -- 附加数据写入文件
        if find then
            util.appendfile(file,s)

            local t = get_task(file)
            if t then
                t.size = (t.size or 0) + #s
                t.cb(file , status , t.size/t.length)
            end
        end

        if status == "closed" then
            break
        end
    end
    client_socket:close()
end
-- 对外接口，下载单个文件（地址，版本路径，文件路径，回调）
function update.get(host, ver_dir,file, cb)
    util.deletefile(file)

    local co = coroutine.wrap(function()
        download(host,ver_dir, file)
    end)
    local t ={
        co = co,
        cb = cb,
        ver_path = ver_dir,
        file = file,
        host = host
    }
    table.insert(update.tasks,t)
end
function update.set_global_cb(_cb , p)
    update.global_cb.cb = _cb
    update.global_cb.params = p
end
-- 对外接口，更新
function update.tick()
    if #(update.tasks) <= 0 then
        return false
    end
    local res = (update.tasks[1].co)()
    if not res then
        table.remove(update.tasks,1)
        if #update.tasks == 0 and update.global_cb.cb then
            update.global_cb.cb(update.global_cb.params)
        end
    end
    return true
end

return update