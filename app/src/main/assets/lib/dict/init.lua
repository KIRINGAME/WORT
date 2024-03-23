local dict = {}
local dict_tab = {}
local dict_book = {}

----------------------------------------------------------------------------
-- const
dict.word_len_min = 3
dict.word_len_max = 7
----------------------------------------------------------------------------
function dict.load_dict(dict_path)
	
	if dict_path == nil or table.empty(dict_path) then
		return
	end
	for i,v in ipairs(dict_path) do
		local _path = v[1]
		local _len = v[2]
		dict.load( _path ,_len)
	end
end

function dict.load( _path ,_len)
	local file_data = util.readfile(_path)
	if file_data == nil then 
		print("load dict failed :".._path)
		return 
	end
	
	-- cache the book name
	dict_book[_len] = _path

	local lines = string.split(file_data,"\n")
	
	local len = _len
	for i=1,#lines do
		local str = lines[i]
		if not str:empty() and not str:null() then 
			if dict_tab[len] == nil then dict_tab[len] = {} end
			local line_tab = dict_tab[len]
			for j=1,len do
				local c = str:utf8sub(j,j)
				if line_tab[c] == nil then
					line_tab[c] = {}
				end
				if j == len then
					line_tab[c][1]=1
				end
				line_tab = line_tab[c]
			end
		end
	end
end
---------------------------------------------

---------------------------------------------
-- 加载字典
function dict.load_dict_word(dict_word_path)	
	if dict_word_path == nil then
		return
	end
    local str = util.readfile(dict_word_path)
	dict.dict_word = table.fromjson(str)
end
---------------------------------------------

---------------------------------------------
-- 创建关卡
function dict.create_stage(dict_path)

	if dict_path == nil or table.empty(dict_path) then
		return
	end

	-- 构建单词对应的子词表
	--准备承接有效不重复的单词
	local table_word = {}
	for i,v in ipairs(dict_path) do
		local path = v[1]
		local word_len = v[2]
		table_word[word_len] = {}

		local file_data = util.readfile(path)
		if file_data == nil then 
			break
		end
		
		--筛选数据源
		local lines = string.split(file_data,"\n")
		local line_num = #lines
		for i,v in ipairs(lines) do
			local word = v:utf8sub(1,word_len)
			--获取子表
			local child_word = dict.get_contain_word(word)
			local child_word_count = #child_word
			if table_word[word_len][child_word_count] == nil then table_word[word_len][child_word_count] = {} end
			local is_contain = false
			for i,_v in ipairs(child_word) do
				--只判断长度最大的单词，低于最大长度的不用看了
				if _v:length() == word_len then
					local contain = table.containValue(table_word[word_len][child_word_count],_v)
					if contain then 
						is_contain = true
						break 
					end
				end
			end
			if not is_contain then
				table.insert( table_word[word_len][child_word_count],word )
			end
		end
	end

	
	local function sort_func(s1, s2)
		if s1:len() < s2:len() then
			return true
		end
		if s1:len() > s2:len() then
			return false
		end
		for i = 1, s1:len() do
			if s1:utf8sub(i,1) < s2:utf8sub(i,1) then
				return true
			elseif s1:utf8sub(i,1) > s2:utf8sub(i,1) then
				return false
			end
		end
		return false
	end

	
	local child_word_count_list = ""
	for k,v in pairs(table_word) do
		for m,n in pairs(v) do
			local temp = {}
			table.copy(temp,n)
			table.sort( temp, sort_func )
			for i,data in ipairs(temp) do
				if data:length() >0 then
					child_word_count_list = child_word_count_list..data.."\n"
				end
			end
		end
	end
	util.savefile("stage_list.txt",child_word_count_list)
	child_word_count_list = ""
end
---------------------------------------------

function dict.load_stage(path)
	local file_data = util.readfile(path)
	if file_data == nil then 
		error("stage list error")
		return
	end
	
	--筛选数据源	
	local osString = love.system.getOS( )
	if osString == "iOS" then
		dict.stage = string.split(file_data,"\n")
	elseif osString == "Android" then
		dict.stage = string.split(file_data,"\r\n")
	elseif osString == "Windows" then
		dict.stage = string.split(file_data,"\r\n")
	end
end
----------------------------------------------------------------------------
-- get all contain word from word
local output_word = output_word or {}
local function get_word(_dict,_prefix,_postfix)
	for i=1,_postfix:utf8len() do
		local _w = _postfix:utf8sub(i,i)
		local _last = _postfix:utf8sub(1,i-1).._postfix:utf8sub(i+1,_postfix:utf8len())
		
		if _dict[_w]~=nil then
			-- 已经有满足的（因为词典都是同等长度的，那么就说明结束了）			
			if _dict[_w][1] == 1 then		
				local new_word = _prefix.._w
			
				if table.containValue(output_word,new_word) == false then
					table.insert( output_word, new_word)
				end
			else				
				get_word(_dict[_w],_prefix.._w,_last)
			end
		end
	end
end

function dict.get_contain_word(str)	
	output_word = {}
	
	local word_len = str:utf8len()
	for i=word_len,dict.word_len_min,-1 do
		local _t = dict_tab[i]	
		get_word(_t,"",str)
	end
	return output_word
end
----------------------------------------------------------------------------
function dict.get_random_word(word_len)
	local _path = dict_book[word_len]
	if _path == nil then return "" end

	local file_data = util.readfile(_path)
	if file_data == nil then return end
	
	local lines = string.split(file_data,"\n")
	local n = math.random( #lines )
	
	return lines[n]:utf8sub(1,word_len)
end

dict.dict_tab = dict_tab

_G["dict"] = dict

return dict