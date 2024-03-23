local timer = {}
timer.serial = {}
timer.serial[1] = {pause = false,pause_time = nil,event = {}}

local event = {}
event.__index = event
function event:start()
    self._f()
end
function event:stop()
    for m,v in ipairs(timer.serial) do
        for i,t in ipairs(v.event) do
            if t == self then
                table.remove(v.event,i)
                break
            end
        end
    end
end

function timer.add_timer( _t,_f ,serial_number)
    --创建事件
    local e = setmetatable({},event)
    local start = love.timer.getTime()
    e._t = start + _t
    e._f = _f

    --默认序列
    if serial_number == nil then
        serial_number = 1
    elseif timer.serial[serial_number] == nil then
        timer.serial[serial_number] = {pause = false,pause_time = nil ,event = {}}
    end

    --添加到序列
    local insert = false
    local s = timer.serial[serial_number]
    for i,t in ipairs(s.event) do
        if t._t > e._t then
            table.insert(s.event,i,e)
            insert = true
            break
        end
    end
    if not insert then
        table.insert(s.event,e)
    end
    return e
end

function timer.update(dt)
    --遍历序列
    if #(timer.serial[1].event) == 0 then
        return
    end
    local now = love.timer.getTime()
    for m,s in ipairs(timer.serial) do
        --遍历事件集合
        if s.pause == false then
            local i = 1
            while i <= #s.event do
                local e = s.event[i]
                if e._t < now then
                    e._f()
                    table.remove(s.event, i)
                else
                    break
                end
            end
        end
    end
end

function timer.pause( serial_number )
    if serial_number == nil then
        serial_number = 1
    end
    local t = timer.serial[serial_number]
    if t.pause == true then
        return 
    end
    t.pause = true
    t.pause_time = love.timer.getTime()
end

function timer.resume(serial_number )
    if serial_number == nil then
        serial_number = 1
    end
    local t = timer.serial[serial_number]
    if t.pause == false then
        return 
    end
    local time = love.timer.getTime() - t.pause_time
    t.pause = false
    t.pause_time = nil
    for i,v in ipairs(t.event) do
        v._t = v._t + time
    end
    
end

_G["timer"] = timer

return timer