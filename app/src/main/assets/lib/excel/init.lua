
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- excel

local util = require("lib/util")
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- metatable
local excel = {}
_G.excel = excel
-- function define
local excel_table = 
{
	--find by id
	find = function(_t,id)
		return _t.data[tonumber(id)]
	end,
	
	-- find by line NUM.
	find_line = function(_t,num)
		local count = 1
		for k,v in pairs(_t.data) do
			if count == num then
				return v
			end
			count = count + 1
		end
	end,
	
	-- return the line count
	count = function(_t)
		return table.count(_t.data)
	end
}
excel_table.__index = excel_table

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- get the table and the title
local function init_table( _table_dir )
	local _dir1 = string.split(_table_dir,"/")
	local _dir = string.split(_dir1[#_dir1],".")
	
	local _table_name = _dir[1]
	if _G.excel[_table_name] == nil then 
		_G.excel[_table_name] = {} 
	end
	local _t = _G.excel[_table_name]
	if _t.data == nil then _t.data = {} end
	if _t.title == nil then _t.title = {} end
	setmetatable( _t , excel_table)
	return _t  
end

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- load the data from files to table
--table
--line
--cell
local cell_type = 
{
	ct_int			=		1,
	ct_sting		=		2,
	ct_array_int	=		3,
	ct_array_string	=		4,
}
local function load_excel( table_dir )
	-- load file
	if string.null(table_dir) or string.empty(table_dir) then return end
	if string.endwith(table_dir,".txt") == false then return end
	
	-- call the function to get all the content
	local file_data = util.readfile(table_dir)	
	if file_data == nil then return end
	
	-- every lines
    local lines = {}
    for w in string.gmatch(file_data, "%a+") do
       table.insert(lines,w) 
    end

	-- check title
	local title_def = {}
	local title_data = string.split(lines[1],"\t")
	
	local _find_key = false --find line index
	local title_count = 1
	for i,v in ipairs(title_data) do
		if string.contains(v,"<") == true then
			local t = {}
			t.column = i
			local s = string.split(v,'>')
			t.name = s[2]

			-- column type
			if s[1] == "<I" then
				t.type = cell_type.ct_int
				-- save the id
				if _find_key == false then
					t.id = true
					_find_key = true
				end	
			elseif s[1] == "<S" then
				t.type = cell_type.ct_string
			elseif s[1] == "<VI" then
				t.type = cell_type.ct_array_int
			elseif s[1] == "<VS" then
				t.type = cell_type.ct_array_string
			end
			title_def[title_count] = t
			title_count = title_count + 1
		end	
	end
	
	-- load data 
	local _t = init_table(table_dir)
	
	-- set title
	_t.title = title_def

	-- set data
	for i=2,#lines do
		local line_data = string.split(lines[i],"\t")
		local data = {}
		local _id = nil
		for i,v in ipairs(title_def) do
			local _value = line_data[v.column]
			if v.id == true then
				_id = tonumber(_value)
			end
			if v.type == cell_type.ct_int then				
				if _value == nil or _value == "" then _value = 0 end
				data[v.name] = tonumber(_value)
			elseif v.type == cell_type.ct_string then
				if _value == nil or _value == "" then _value = "" end
				data[v.name] = tostring(_value)
			elseif v.type == cell_type.ct_array_int then
				if _value == nil or _value == "" then _value = "" end
				local t = string.split(_value,"*") or {}
				local _data = {}
				for i,v in ipairs(t) do
					table.insert(_data,tonumber(v))
				end
				data[v.name] = _data
			elseif v.type == cell_type.ct_array_string then
				if _value == nil or _value == "" then _value = "" end
				data[v.name] = string.split(_value,"*") or {}
			end
		end
		if _id ~= nil then
			_t.data[_id] = data
		end
	end	
end
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

---------------------------------------------------------------

excel.load_excel = load_excel
return excel


