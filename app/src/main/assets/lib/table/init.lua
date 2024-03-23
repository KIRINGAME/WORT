require("lib/json")
function table.count(t)
    if t == nil then return 0 end
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

function table.keys(t)
    local keys = {}
    if t == nil then
        return keys;
    end
    for k, v in pairs(t) do
        keys[#keys + 1] = k
    end
    return keys
end

function table.values(t)
    local values = {}
    if t == nil then
        return values;
    end
    for k, v in pairs(t) do
        values[#values + 1] = v
    end
    return values
end

function table.containKey( t, key )
    if(t == nil or type(t) ~= "table") then
        return false
    end
    for k, v in pairs(t) do
        if key == k then
            return true;
        end
    end
    return false;
end

function table.containValue( t, value )
    if(t == nil or type(t) ~= "table") then
        return false
    end
    for k, v in pairs(t) do
        if value == v then
            return true;
        end
    end
    return false;
end

function table.getKeyByValue( t, value )
    for k, v in pairs(t) do
        if value == v then
            return k;
        end
    end
end
--适用于有key的合并,可能会出现覆盖问题
function table.merge_map(dest, src)
	if src == nil then return end
    for k, v in pairs(src) do
        dest[k] = v
    end
end
--适用于默认key(1，2，3，4。。。)这类结构一直的合并
function table.merge_array( dest, src )
    if type(dest) ~= "table" then return end
    if src == nil then return end
    for k,v in pairs(src) do
        insert(dest,v)
    end
end

function table.copy(dest, src)
	if src == nil then return end
	for k, v in pairs(src) do
		if type(v) == "table" then
			local t = {}
			table.copy(t,v)
			dest[k] = t
		else
			dest[k] = v
		end
	end
end

function table.empty(t)
    return next(t) == nil
end

-- Returns a value representing the decoded JSON string.
function table.fromjson(str)
    if str == nil or str == "" then return {} end
    return json.decode(str)
end
-- Returns a string representing value encoded in JSON.
function table.tojson(t)
    return json.encode(t)
end
function table.print(t)
    print(json.encode(t))
end

--  求交集 --
function table.get_intersection( _tab1, _tab2 )
   local ret = {}
   for k,v in pairs(_tab1) do
        if( containValue(_tab2, v) ) then
            insert(ret, v)
        end
   end
   return ret
end

-- 求并集 --
function table.get_union( _tab1, _tab2 )
    local ret = {}
    for k,v in pairs(_tab1) do
        if( containValue(_tab2, v) == false ) then
            insert(ret, v)
        end
    end
    for k,v in pairs(_tab2) do
        if( containValue(_tab1, v) == false ) then
            insert(ret, v)
        end
    end
    local insersectiontab = get_intersection(_tab1, _tab2)
    merge1(ret, insersectiontab)
    return ret
end

-- 清空
function table.clear(_table )
    for i = #_table,1,-1 do
        table.remove(_table,i)
    end
end
