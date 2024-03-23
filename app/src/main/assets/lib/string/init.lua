
-------------------------------------------------------------------------------------------------
-- 字符串处理库
-- 如果str包含sub, 则返回true
function string.contains(str, sub)
    return str:find(sub, nil, true) ~= nil
end

-- 以sep(为特殊字符, 使用模式匹配)为分割符将str分割为一个table
-- maxsplit : 最大分割次数, 默认为全部分割
-- include  : 返回的table中是否包含分隔符
-- plain    : 分隔符是否进行模式匹配, 默认为不使用
function string.split(str, sep, maxsplit, include, plain)
    if not sep or sep == '' then
        local res = {}
        local key = 0
        for c in str:gmatch('.') do
            key = key + 1
            res[key] = c
        end
        return res
    end

    maxsplit = maxsplit or 0
    if plain == nil then
        plain = true
    end

    local res = {}
    local key = 0
    local i = 1
    local startpos, endpos
    local match
    while i <= #str + 1 do
        -- 查找下一个分割点
        startpos, endpos = str:find(sep, i, plain)
        -- 如果找到插入表中
        if startpos then
            match = str:sub(i, startpos - 1)
            key = key + 1
            res[key] = match

            if include then
                key = key + 1
                res[key] = str:sub(startpos, endpos)
            end

            -- 如果达到最大分割次数了, 结束遍历
            if key == maxsplit - 1 then
                key = key + 1
                res[key] = str:sub(endpos + 1)
                break
            end
            i = endpos + 1
        -- 如果没找到, 那么把剩下的内容插入表中, 并结束遍历
        else
            key = key + 1
            res[key] = str:sub(i)
            break
        end
    end

    return res
end

function string.split1(str,delimiter)
    if str == nil or str == '' or delimiter == nil then
        return nil
    end

    local result = {}
    local p = "[^"..table.concat(delimiter).."]+"
    for match in str:gmatch(p) do
        table.insert(result,match)
    end
    return result
end

-- sub的包装
function string.slice(str, from, to)
    return str:sub(from or 1, to or #str)
end

-- 返回一个遍历str的迭代器
function string.it(str)
    return str:gmatch('.')
end

-- 去除str的前后空白符
function string.trim(str)
    return str:match('^%s*(.-)%s*$')
end

-- 将str所有空白字符替换为一个空白符
function string.spaces_collapse(str)
    return str:gsub('%s+', ' '):trim()
end

-- 将str中所有包含在chars中的字符移除
function string.stripchars(str, chars)
    return (str:gsub('['..chars:escape()..']', ''))
end

-- 返回str的字符长度
function string.length(str)
    return #str
end

-- 检测str是否以substr开始
function string.startwith(str, substr)
    return str:sub(1, #substr) == substr
end

-- 检测str是否以substr结束
function string.endwith(str, substr)
    return str:sub(-#substr) == substr
end

-- 空串判断
function string.empty(str)
    return str == ''
end
function string.null(str)
    return str == nil
end
function string.isnullorempty(str)
    return str == '' or str == nil
end

-- 将特殊字符进行转移处理
function string.escape(str)
    return (str:gsub('[[%]%%^$*()%.%+?-]', '%%%1'))
end

-- pat在str中出现的次数
function string.pcount(str, pat)
    local _, c = gsub(str, pat, '')
    return c
end
-- sub在str中出现的次数
function string.count(str, sub)
    return str:pcount(sub:escape())
end

function string.stringtoarray(str)
    local arr = str:sub(2,-2):split1(',')
    for i=1,#arr do
        arr[i] = tonumber(arr[i])
    end
    return arr
end

function string.arraytostring(arr)
    local str = ""
    for i=1,#arr-1 do
        str = str..arr[i]..","
    end
    str = str..arr[#arr]
    str = "["..str.."]"
    return str
end

-- utf8 to utf16--

local function checkutf8followchar(str, startidx, length)
    for i = startidx + 1, startidx + length do
        local b = str:byte(i)
        if b < 128 and b >= 192 then
            return false
        end
    end
        return true
end

function string.utf8toutf16(str)
    local idx = 1
    local strLen = #str
    local utf16code = {}
    while idx <= strLen do
        local b = str:byte(idx)
        if b < 128 then
            table.insert(utf16code, b)
            idx = idx + 1
        elseif b < 192 then
            return nil
        elseif b < 224 and checkutf8followchar(str, idx, 1) then
            if idx < strLen then
                local wc = bit32.bor(bit32.lshift(bit32.band(b, 0x1f), 6), bit32.band(str:byte(idx+1), 0x3f))
                table.insert(utf16code, wc)
                idx = idx + 2
            else
                return nil
            end
        elseif b < 240 and checkutf8followchar(str, idx, 2) then
            if idx < strLen - 1 then
                local wc = bit32.bor(bit32.lshift(bit32.band(b, 0xf), 12), bit32.lshift(bit32.band(str:byte(idx+1), 0x3f), 6), bit32.band(str:byte(idx+2), 0x3f))
                table.insert(utf16code, wc)
                idx = idx + 3
            else
                return nil
            end
        elseif b < 248 and checkutf8followchar(str, idx, 3) then
            if idx < strLen - 2 then
                local wc = bit32.bor(bit32.lshift(bit32.band(b, 0x7), 18), bit32.lshift(bit32.band(b, 0xf), 12), bit32.lshift(bit32.band(str:byte(idx+1), 0x3f), 6), bit32.band(str:byte(idx+2), 0x3f))
                table.insert(utf16code, wc)
                idx = idx + 4
            else
                return nil
            end
        elseif b < 252 and checkutf8followchar(str, idx, 4) then
            if idx < strLen - 3 then
                local wc = bit32.bor(bit32.lshift(bit32.band(b, 0x3), 24), bit32.lshift(bit32.band(b, 0xf), 18), bit32.lshift(bit32.band(b, 0xf), 12), bit32.lshift(bit32.band(str:byte(idx+1), 0x3f), 6), bit32.band(str:byte(idx+2), 0x3f))
                table.insert(utf16code, wc)
                idx = idx + 5
            else
                return nil
            end
        elseif b < 254 and checkutf8followchar(str, idx, 5) then
            if idx < strLen - 4 then
                local wc = bit32.bor(bit32.lshift(bit32.band(b, 0x1), 30), bit32.lshift(bit32.band(b, 0xf), 24), bit32.lshift(bit32.band(b, 0xf), 18), bit32.lshift(bit32.band(b, 0xf), 12), bit32.lshift(bit32.band(str:byte(idx+1), 0x3f), 6), bit32.band(str:byte(idx+2), 0x3f))
                table.insert(utf16code, wc)
                idx = idx + 6
            else
                return nil
            end
        end
    end
    return utf16code
end
function string.utf8toutf16_brackets(str)
    local idx = 1
    local strLen = #str
    local table_utf16code_list = {}

    local utf16code = {}
    local _color_flag = false
    local color = ""
    while idx <= strLen do
        local b = str:byte(idx)
        if b < 128 then
            if b == 60 then
                -- <

                local c = str:byte(idx+1)
                if c == 99 then
                    -- c
                    table.insert(table_utf16code_list, {text=utf16code,color=color})
                    utf16code = {}
                    color = str:sub(idx,idx+11)
                    idx = idx + 12
                elseif c == 47 then
                    -- /
                    table.insert(table_utf16code_list, {text=utf16code,color=color})
                    utf16code = {}
                    color = ""
                    idx = idx + 4
                else
                    --其他控制符
                    local i = 1
                    while idx+i<=strLen do
                        local _other_c = str:byte(idx+i)
                        if _other_c == 62 then
                            -- >
                            break
                        end
                        i = i + 1
                    end
                    b = str:sub(idx,idx+i)
                    table.insert(utf16code, b)
                    idx = idx+i+1
                end
            else
                --没有控制符，正常ASCII
                table.insert(utf16code, b)
                idx = idx + 1
            end
        elseif b < 192 then
            return nil
        elseif b < 224 and checkutf8followchar(str, idx, 1) then
            if idx < strLen then
                local wc = bit32.bor(bit32.lshift(bit32.band(b, 0x1f), 6), bit32.band(str:byte(idx+1), 0x3f))
                table.insert(utf16code, wc)
                idx = idx + 2
            else
                return nil
            end
        elseif b < 240 and checkutf8followchar(str, idx, 2) then
            if idx < strLen - 1 then
                local wc = bit32.bor(bit32.lshift(bit32.band(b, 0xf), 12), bit32.lshift(bit32.band(str:byte(idx+1), 0x3f), 6), bit32.band(str:byte(idx+2), 0x3f))
                table.insert(utf16code, wc)
                idx = idx + 3
            else
                return nil
            end
        elseif b < 248 and checkutf8followchar(str, idx, 3) then
            if idx < strLen - 2 then
                local wc = bit32.bor(bit32.lshift(bit32.band(b, 0x7), 18), bit32.lshift(bit32.band(b, 0xf), 12), bit32.lshift(bit32.band(str:byte(idx+1), 0x3f), 6), bit32.band(str:byte(idx+2), 0x3f))
                table.insert(utf16code, wc)
                idx = idx + 4
            else
                return nil
            end
        elseif b < 252 and checkutf8followchar(str, idx, 4) then
            if idx < strLen - 3 then
                local wc = bit32.bor(bit32.lshift(bit32.band(b, 0x3), 24), bit32.lshift(bit32.band(b, 0xf), 18), bit32.lshift(bit32.band(b, 0xf), 12), bit32.lshift(bit32.band(str:byte(idx+1), 0x3f), 6), bit32.band(str:byte(idx+2), 0x3f))
                table.insert(utf16code, wc)
                idx = idx + 5
            else
                return nil
            end
        elseif b < 254 and checkutf8followchar(str, idx, 5) then
            if idx < strLen - 4 then
                local wc = bit32.bor(bit32.lshift(bit32.band(b, 0x1), 30), bit32.lshift(bit32.band(b, 0xf), 24), bit32.lshift(bit32.band(b, 0xf), 18), bit32.lshift(bit32.band(b, 0xf), 12), bit32.lshift(bit32.band(str:byte(idx+1), 0x3f), 6), bit32.band(str:byte(idx+2), 0x3f))
                table.insert(utf16code, wc)
                idx = idx + 6
            else
                return nil
            end
        end
    end

    if next(utf16code) ~= nil then 
        table.insert(table_utf16code_list, {text=utf16code,color=color})
    end
    return table_utf16code_list
end

local g_th_char_prop =
{
    0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,
    0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,
    0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x00,
    0x00,0x03,0x02,0x03,0x03,0x03,0x03,0x03,0x01,0x01,0x00,0x00,0x00,0x00,0x00,0x00,
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x03,0x04,0x04,0x04,0x04,0x03,0x03,0x03,0x00,
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
}

function string.get_str_length(str)
    local utf16code = utf8toutf16(str)
    if utf16code ~= nil then
        local readableLength = 0
        local i = 1
        while i<=#utf16code do
            local wc = utf16code[i]
            if wc > 0x0e00 and wc < 0x0e50 then
                --print(string.format('%04x | %d', wc, g_th_char_prop[wc - 0x0e00]))
                if g_th_char_prop[wc - 0x0e00] == 2 then
                    readableLength = readableLength + 1
                end
            else
                --print(string.format('%04x', wc))
                if wc == 60 then
                    -- <
                    for n_i=i,#utf16code do
                        if utf16code[n_i] == 62 then
                            -->
                            i = n_i
                            readableLength = readableLength + 1
                            break
                        end
                    end
                else
                    readableLength = readableLength + 1
                end
            end
            i = i+1
        end
        return readableLength
    else
        return -1
    end
end


function string.unicodetoutf8(unicode)

    if type(unicode)~="number" then
        -- print("wrong type", type(unicode))
        return unicode
    end

    local resultStr=""

    if unicode <= 0x007f then


        resultStr=resultStr..string.char(bit32.band(unicode,0x7f))


    elseif unicode >= 0x0080 and unicode <= 0x07ff then

        resultStr=resultStr..string.char(bit32.bor(0xc0,bit32.band(bit32.rshift(unicode,6),0x1f)))

        resultStr=resultStr..string.char(bit32.bor(0x80,bit32.band(unicode,0x3f)))


    elseif unicode >= 0x0800 and unicode <= 0xffff then


        resultStr=resultStr..string.char(bit32.bor(0xe0,bit32.band(bit32.rshift(unicode,12),0x0f)))

        resultStr=resultStr..string.char(bit32.bor(0x80,bit32.band(bit32.rshift(unicode,6),0x3f)))

        resultStr=resultStr..string.char(bit32.bor(0x80,bit32.band(unicode,0x3f)))


    end


    return resultStr

end

function string.unicode_sub( _utf8_str, _bg, _ed )
    local unicode_str_tab = utf8toutf16( _utf8_str )
    local new_tab = {}

    local bg,ed = 0
    local size = #unicode_str_tab
    if( _bg < 1 ) then
        bg = 1
    elseif( _bg > size ) then
        bg = size
    else
        bg = _bg
    end

    if(_ed < 1) then
        ed = 1
    elseif(_ed > size) then
        ed = size
    else
        ed = _ed
    end
 
    for i=bg, ed do
        table.insert( new_tab, unicode_str_tab[i] )
    end

    local str = ""
    for i=1,#new_tab do
        str = str..unicodetoutf8(new_tab[i])
    end

    return str
end

-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- utf8

-- $Id: utf8.lua 179 2009-04-03 18:10:03Z pasta $
--
-- Provides UTF-8 aware string functions implemented in pure lua:
-- * utf8len(s)
-- * utf8sub(s, i, j)
-- * utf8reverse(s)
-- * utf8char(unicode)
-- * utf8unicode(s, i, j)
-- * utf8gensub(s, sub_len)
-- * utf8find(str, regex, init, plain)
-- * utf8match(str, regex, init)
-- * utf8gmatch(str, regex, all)
-- * utf8gsub(str, regex, repl, limit)
--
-- If utf8data.lua (containing the lower<->upper case mappings) is loaded, these
-- additional functions are available:
-- * utf8upper(s)
-- * utf8lower(s)
--
-- All functions behave as their non UTF-8 aware counterparts with the exception
-- that UTF-8 characters are used instead of bytes for all units.

--[[
Copyright (c) 2006-2007, Kyle Smith
All rights reserved.
Contributors:
	Alimov Stepan
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the author nor the names of its contributors may be
      used to endorse or promote products derived from this software without
      specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

-- ABNF from RFC 3629
-- 
-- UTF8-octets = *( UTF8-char )
-- UTF8-char   = UTF8-1 / UTF8-2 / UTF8-3 / UTF8-4
-- UTF8-1      = %x00-7F
-- UTF8-2      = %xC2-DF UTF8-tail
-- UTF8-3      = %xE0 %xA0-BF UTF8-tail / %xE1-EC 2( UTF8-tail ) /
--               %xED %x80-9F UTF8-tail / %xEE-EF 2( UTF8-tail )
-- UTF8-4      = %xF0 %x90-BF 2( UTF8-tail ) / %xF1-F3 3( UTF8-tail ) /
--               %xF4 %x80-8F 2( UTF8-tail )
-- UTF8-tail   = %x80-BF
-- 

local byte    = string.byte
local char    = string.char
local dump    = string.dump
local find    = string.find
local format  = string.format
local gmatch  = string.gmatch
local gsub    = string.gsub
local len     = string.len
local lower   = string.lower
local match   = string.match
local rep     = string.rep
local reverse = string.reverse
local sub     = string.sub
local upper   = string.upper

-- returns the number of bytes used by the UTF-8 character at byte i in s
-- also doubles as a UTF-8 character validator
local function utf8charbytes (s, i)
	-- argument defaults
	i = i or 1

	-- argument checking
	if type(s) ~= "string" then
		error("bad argument #1 to 'utf8charbytes' (string expected, got ".. type(s).. ")")
	end
	if type(i) ~= "number" then
		error("bad argument #2 to 'utf8charbytes' (number expected, got ".. type(i).. ")")
	end

	local c = byte(s, i)

	-- determine bytes needed for character, based on RFC 3629
	-- validate byte 1
	if c > 0 and c <= 127 then
		-- UTF8-1
		return 1

	elseif c >= 194 and c <= 223 then
		-- UTF8-2
		local c2 = byte(s, i + 1)

		if not c2 then
			error("UTF-8 string terminated early")
		end

		-- validate byte 2
		if c2 < 128 or c2 > 191 then
			error("Invalid UTF-8 character")
		end

		return 2

	elseif c >= 224 and c <= 239 then
		-- UTF8-3
		local c2 = byte(s, i + 1)
		local c3 = byte(s, i + 2)

		if not c2 or not c3 then
			error("UTF-8 string terminated early")
		end

		-- validate byte 2
		if c == 224 and (c2 < 160 or c2 > 191) then
			error("Invalid UTF-8 character")
		elseif c == 237 and (c2 < 128 or c2 > 159) then
			error("Invalid UTF-8 character")
		elseif c2 < 128 or c2 > 191 then
			error("Invalid UTF-8 character")
		end

		-- validate byte 3
		if c3 < 128 or c3 > 191 then
			error("Invalid UTF-8 character")
		end

		return 3

	elseif c >= 240 and c <= 244 then
		-- UTF8-4
		local c2 = byte(s, i + 1)
		local c3 = byte(s, i + 2)
		local c4 = byte(s, i + 3)

		if not c2 or not c3 or not c4 then
			error("UTF-8 string terminated early")
		end

		-- validate byte 2
		if c == 240 and (c2 < 144 or c2 > 191) then
			error("Invalid UTF-8 character")
		elseif c == 244 and (c2 < 128 or c2 > 143) then
			error("Invalid UTF-8 character")
		elseif c2 < 128 or c2 > 191 then
			error("Invalid UTF-8 character")
		end
		
		-- validate byte 3
		if c3 < 128 or c3 > 191 then
			error("Invalid UTF-8 character")
		end

		-- validate byte 4
		if c4 < 128 or c4 > 191 then
			error("Invalid UTF-8 character")
		end

		return 4

	else
		error("Invalid UTF-8 character")
	end
end

-- returns the number of characters in a UTF-8 string
local function utf8len (s)
	-- argument checking
	if type(s) ~= "string" then
		for k,v in pairs(s) do print('"',tostring(k),'"',tostring(v),'"') end
		error("bad argument #1 to 'utf8len' (string expected, got ".. type(s).. ")")
	end

	local pos = 1
	local bytes = len(s)
	local len = 0

	while pos <= bytes do
		len = len + 1
		pos = pos + utf8charbytes(s, pos)
	end

	return len
end

-- functions identically to string.sub except that i and j are UTF-8 characters
-- instead of bytes
local function utf8sub (s, i, j)
	-- argument defaults
	j = j or -1

	local pos = 1
	local bytes = len(s)
	local len = 0

	-- only set l if i or j is negative
	local l = (i >= 0 and j >= 0) or utf8len(s)
	local startChar = (i >= 0) and i or l + i + 1
	local endChar   = (j >= 0) and j or l + j + 1

	-- can't have start before end!
	if startChar > endChar then
		return ""
	end

	-- byte offsets to pass to string.sub
	local startByte,endByte = 1,bytes
	
	while pos <= bytes do
		len = len + 1

		if len == startChar then
			startByte = pos
		end

		pos = pos + utf8charbytes(s, pos)

		if len == endChar then
			endByte = pos - 1
			break
		end
	end
	
	if startChar > len then startByte = bytes+1   end
	if endChar   < 1   then endByte   = 0         end
	
	return sub(s, startByte, endByte)
end


-- replace UTF-8 characters based on a mapping table
local function utf8replace (s, mapping)
	-- argument checking
	if type(s) ~= "string" then
		error("bad argument #1 to 'utf8replace' (string expected, got ".. type(s).. ")")
	end
	if type(mapping) ~= "table" then
		error("bad argument #2 to 'utf8replace' (table expected, got ".. type(mapping).. ")")
	end

	local pos = 1
	local bytes = len(s)
	local charbytes
	local newstr = ""

	while pos <= bytes do
		charbytes = utf8charbytes(s, pos)
		local c = sub(s, pos, pos + charbytes - 1)

		newstr = newstr .. (mapping[c] or c)

		pos = pos + charbytes
	end

	return newstr
end


-- identical to string.upper except it knows about unicode simple case conversions
local function utf8upper (s)
	return utf8replace(s, utf8_lc_uc)
end

-- identical to string.lower except it knows about unicode simple case conversions
local function utf8lower (s)
	return utf8replace(s, utf8_uc_lc)
end

-- identical to string.reverse except that it supports UTF-8
local function utf8reverse (s)
	-- argument checking
	if type(s) ~= "string" then
		error("bad argument #1 to 'utf8reverse' (string expected, got ".. type(s).. ")")
	end

	local bytes = len(s)
	local pos = bytes
	local charbytes
	local newstr = ""

	while pos > 0 do
		c = byte(s, pos)
		while c >= 128 and c <= 191 do
			pos = pos - 1
			c = byte(s, pos)
		end

		charbytes = utf8charbytes(s, pos)

		newstr = newstr .. sub(s, pos, pos + charbytes - 1)

		pos = pos - 1
	end

	return newstr
end

-- http://en.wikipedia.org/wiki/Utf8
-- http://developer.coronalabs.com/code/utf-8-conversion-utility
local function utf8char(unicode)
	if unicode <= 0x7F then return char(unicode) end
	
	if (unicode <= 0x7FF) then
		local Byte0 = 0xC0 + math.floor(unicode / 0x40);
		local Byte1 = 0x80 + (unicode % 0x40);
		return char(Byte0, Byte1);
	end;
	
	if (unicode <= 0xFFFF) then
		local Byte0 = 0xE0 +  math.floor(unicode / 0x1000);
		local Byte1 = 0x80 + (math.floor(unicode / 0x40) % 0x40);
		local Byte2 = 0x80 + (unicode % 0x40);
		return char(Byte0, Byte1, Byte2);
	end;
	
	if (unicode <= 0x10FFFF) then
		local code = unicode
		local Byte3= 0x80 + (code % 0x40);
		code       = math.floor(code / 0x40)
		local Byte2= 0x80 + (code % 0x40);
		code       = math.floor(code / 0x40)
		local Byte1= 0x80 + (code % 0x40);
		code       = math.floor(code / 0x40)  
		local Byte0= 0xF0 + code;
		
		return char(Byte0, Byte1, Byte2, Byte3);
	end;
	
	error 'Unicode cannot be greater than U+10FFFF!'
end

local shift_6  = 2^6
local shift_12 = 2^12
local shift_18 = 2^18

local utf8unicode
utf8unicode = function(str, i, j, byte_pos)
	i = i or 1
	j = j or i
	
	if i > j then return end
	
	local char,bytes
	
	if byte_pos then 
		bytes = utf8charbytes(str,byte_pos)
		char  = sub(str,byte_pos,byte_pos-1+bytes)
	else
		char,byte_pos = utf8sub(str,i,i), 0
		bytes         = #char
	end
	
	local unicode
	
	if bytes == 1 then unicode = byte(char) end
	if bytes == 2 then
		local byte0,byte1 = byte(char,1,2)
		local code0,code1 = byte0-0xC0,byte1-0x80
		unicode = code0*shift_6 + code1
	end
	if bytes == 3 then
		local byte0,byte1,byte2 = byte(char,1,3)
		local code0,code1,code2 = byte0-0xE0,byte1-0x80,byte2-0x80
		unicode = code0*shift_12 + code1*shift_6 + code2
	end
	if bytes == 4 then
		local byte0,byte1,byte2,byte3 = byte(char,1,4)
		local code0,code1,code2,code3 = byte0-0xF0,byte1-0x80,byte2-0x80,byte3-0x80
		unicode = code0*shift_18 + code1*shift_12 + code2*shift_6 + code3
	end
	
	return unicode,utf8unicode(str, i+1, j, byte_pos+bytes)
end

-- Returns an iterator which returns the next substring and its byte interval
local function utf8gensub(str, sub_len)
	sub_len        = sub_len or 1
	local byte_pos = 1
	local len      = #str
	return function(skip)
		if skip then byte_pos = byte_pos + skip end
		local char_count = 0
		local start      = byte_pos
		repeat
			if byte_pos > len then return end
			char_count  = char_count + 1
			local bytes = utf8charbytes(str,byte_pos)
			byte_pos    = byte_pos+bytes
			
		until char_count == sub_len
		
		local last  = byte_pos-1
		local sub   = sub(str,start,last)
		return sub, start, last
	end
end

local function binsearch(sortedTable, item, comp)
	local head, tail = 1, #sortedTable
	local mid = math.floor((head + tail)/2)
	if not comp then
		while (tail - head) > 1 do
			if sortedTable[tonumber(mid)] > item then
				tail = mid
			else
				head = mid
			end
			mid = math.floor((head + tail)/2)
		end
	else
	end
	if sortedTable[tonumber(head)] == item then
		return true, tonumber(head)
	elseif sortedTable[tonumber(tail)] == item then
		return true, tonumber(tail)
	else
		return false
	end
end
local function classMatchGenerator(class, plain)
	local codes = {}
	local ranges = {}
	local ignore = false
	local range = false
	local firstletter = true
	local unmatch = false
	
	local it = utf8gensub(class) 
	
	local skip
	for c,bs,be in it do
		skip = be
		if not ignore and not plain then
			if c == "%" then
				ignore = true
			elseif c == "-" then
				table.insert(codes, utf8unicode(c))
				range = true
			elseif c == "^" then
				if not firstletter then
					error('!!!')
				else
					unmatch = true
				end
			elseif c == ']' then
				break
			else
				if not range then
					table.insert(codes, utf8unicode(c))
				else
					table.remove(codes) -- removing '-'
					table.insert(ranges, {table.remove(codes), utf8unicode(c)})
					range = false
				end
			end
		elseif ignore and not plain then
			if c == 'a' then -- %a: represents all letters. (ONLY ASCII)
				table.insert(ranges, {65, 90}) -- A - Z
				table.insert(ranges, {97, 122}) -- a - z
			elseif c == 'c' then -- %c: represents all control characters.
				table.insert(ranges, {0, 31})
				table.insert(codes, 127)
			elseif c == 'd' then -- %d: represents all digits.
				table.insert(ranges, {48, 57}) -- 0 - 9
			elseif c == 'g' then -- %g: represents all printable characters except space.
				table.insert(ranges, {1, 8})
				table.insert(ranges, {14, 31})
				table.insert(ranges, {33, 132})
				table.insert(ranges, {134, 159})
				table.insert(ranges, {161, 5759})
				table.insert(ranges, {5761, 8191})
				table.insert(ranges, {8203, 8231})
				table.insert(ranges, {8234, 8238})
				table.insert(ranges, {8240, 8286})
				table.insert(ranges, {8288, 12287})
			elseif c == 'l' then -- %l: represents all lowercase letters. (ONLY ASCII)
				table.insert(ranges, {97, 122}) -- a - z
			elseif c == 'p' then -- %p: represents all punctuation characters. (ONLY ASCII)
				table.insert(ranges, {33, 47})
				table.insert(ranges, {58, 64})
				table.insert(ranges, {91, 96})
				table.insert(ranges, {123, 126})
			elseif c == 's' then -- %s: represents all space characters.
				table.insert(ranges, {9, 13})
				table.insert(codes, 32)
				table.insert(codes, 133)
				table.insert(codes, 160)
				table.insert(codes, 5760)
				table.insert(ranges, {8192, 8202})
				table.insert(codes, 8232)
				table.insert(codes, 8233)
				table.insert(codes, 8239)
				table.insert(codes, 8287)
				table.insert(codes, 12288)
			elseif c == 'u' then -- %u: represents all uppercase letters. (ONLY ASCII)
				table.insert(ranges, {65, 90}) -- A - Z
			elseif c == 'w' then -- %w: represents all alphanumeric characters. (ONLY ASCII)
				table.insert(ranges, {48, 57}) -- 0 - 9
				table.insert(ranges, {65, 90}) -- A - Z
				table.insert(ranges, {97, 122}) -- a - z
			elseif c == 'x' then -- %x: represents all hexadecimal digits.
				table.insert(ranges, {48, 57}) -- 0 - 9
				table.insert(ranges, {65, 70}) -- A - F
				table.insert(ranges, {97, 102}) -- a - f
			else
				if not range then
					table.insert(codes, utf8unicode(c))
				else
					table.remove(codes) -- removing '-'
					table.insert(ranges, {table.remove(codes), utf8unicode(c)})
					range = false
				end
			end
			ignore = false
		else
			if not range then
				table.insert(codes, utf8unicode(c))
			else
				table.remove(codes) -- removing '-'
				table.insert(ranges, {table.remove(codes), utf8unicode(c)})
				range = false
			end
			ignore = false
		end
		
		firstletter = false
	end
	
	table.sort(codes)
	
	local function inRanges(charCode)
		for _,r in ipairs(ranges) do
			if r[1] <= charCode and charCode <= r[2] then
				return true
			end
		end
		return false
	end
	if not unmatch then 
		return function(charCode)
			return binsearch(codes, charCode) or inRanges(charCode) 
		end, skip
	else
		return function(charCode)
			return charCode ~= -1 and not (binsearch(codes, charCode) or inRanges(charCode))
		end, skip
	end
end

-- utf8sub with extra argument, and extra result value 
local function utf8subWithBytes (s, i, j, sb)
	-- argument defaults
	j = j or -1

	local pos = sb or 1
	local bytes = len(s)
	local len = 0

	-- only set l if i or j is negative
	local l = (i >= 0 and j >= 0) or utf8len(s)
	local startChar = (i >= 0) and i or l + i + 1
	local endChar   = (j >= 0) and j or l + j + 1

	-- can't have start before end!
	if startChar > endChar then
		return ""
	end

	-- byte offsets to pass to string.sub
	local startByte,endByte = 1,bytes
	
	while pos <= bytes do
		len = len + 1

		if len == startChar then
			startByte = pos
		end

		pos = pos + utf8charbytes(s, pos)

		if len == endChar then
			endByte = pos - 1
			break
		end
	end
	
	if startChar > len then startByte = bytes+1   end
	if endChar   < 1   then endByte   = 0         end
	
	return sub(s, startByte, endByte), endByte + 1
end

local cache = setmetatable({},{
	__mode = 'kv'
})
local cachePlain = setmetatable({},{
	__mode = 'kv'
})
local function matcherGenerator(regex, plain)
	local matcher = {
		functions = {},
		captures = {}
	}
	if not plain then
		cache[regex] =  matcher
	else
		cachePlain[regex] = matcher
	end
	local function simple(func)
		return function(cC) 
			if func(cC) then
				matcher:nextFunc()
				matcher:nextStr()
			else
				matcher:reset()
			end
		end
	end
	local function star(func)
		return function(cC)
			if func(cC) then
				matcher:fullResetOnNextFunc()
				matcher:nextStr()
			else
				matcher:nextFunc()
			end
		end
	end
	local function minus(func)
		return function(cC)
			if func(cC) then
				matcher:fullResetOnNextStr()
			end
			matcher:nextFunc()
		end
	end
	local function question(func)
		return function(cC)
			if func(cC) then
				matcher:fullResetOnNextFunc()
				matcher:nextStr()
			end
			matcher:nextFunc()
		end
	end
	
	local function capture(id)
		return function(cC)
			local l = matcher.captures[id][2] - matcher.captures[id][1]
			local captured = utf8sub(matcher.string, matcher.captures[id][1], matcher.captures[id][2])
			local check = utf8sub(matcher.string, matcher.str, matcher.str + l)
			if captured == check then
				for i = 0, l do
					matcher:nextStr()
				end
				matcher:nextFunc()
			else
				matcher:reset()
			end
		end
	end
	local function captureStart(id)
		return function(cC)
			matcher.captures[id][1] = matcher.str
			matcher:nextFunc()
		end
	end
	local function captureStop(id)
		return function(cC)
			matcher.captures[id][2] = matcher.str - 1
			matcher:nextFunc()
		end
	end
	
	local function balancer(str)
		local sum = 0
		local bc, ec = utf8sub(str, 1, 1), utf8sub(str, 2, 2)
		local skip = len(bc) + len(ec)
		bc, ec = utf8unicode(bc), utf8unicode(ec)
		return function(cC)
			if cC == ec and sum > 0 then
				sum = sum - 1
				if sum == 0 then
					matcher:nextFunc()
				end
				matcher:nextStr()
			elseif cC == bc then
				sum = sum + 1
				matcher:nextStr()
			else
				if sum == 0 or cC == -1 then
					sum = 0
					matcher:reset()
				else
					matcher:nextStr()
				end
			end
		end, skip
	end
	
	matcher.functions[1] = function(cC)
		matcher:fullResetOnNextStr()
		matcher.seqStart = matcher.str
		matcher:nextFunc()
		if (matcher.str > matcher.startStr and matcher.fromStart) or matcher.str >= matcher.stringLen then
			matcher.stop = true
			matcher.seqStart = nil
		end
	end
	
	local lastFunc
	local ignore = false
	local skip = nil
	local it = (function()
		local gen = utf8gensub(regex)
		return function()
			return gen(skip)
		end
	end)()
	local cs = {}
	for c, bs, be in it do
		skip = nil
		if plain then
			table.insert(matcher.functions, simple(classMatchGenerator(c, plain)))
		else
			if ignore then
				if find('123456789', c, 1, true) then
					if lastFunc then
						table.insert(matcher.functions, simple(lastFunc))
						lastFunc = nil
					end
					table.insert(matcher.functions, capture(tonumber(c)))
				elseif c == 'b' then
					if lastFunc then
						table.insert(matcher.functions, simple(lastFunc))
						lastFunc = nil
					end
					local b
					b, skip = balancer(sub(regex, be + 1, be + 9))
					table.insert(matcher.functions, b)
				else
					lastFunc = classMatchGenerator('%' .. c)
				end
				ignore = false
			else
				if c == '*' then
					if lastFunc then
						table.insert(matcher.functions, star(lastFunc))
						lastFunc = nil
					else
						error('invalid regex after ' .. sub(regex, 1, bs))
					end
				elseif c == '+' then
					if lastFunc then
						table.insert(matcher.functions, simple(lastFunc))
						table.insert(matcher.functions, star(lastFunc))
						lastFunc = nil
					else
						error('invalid regex after ' .. sub(regex, 1, bs))
					end
				elseif c == '-' then
					if lastFunc then
						table.insert(matcher.functions, minus(lastFunc))
						lastFunc = nil
					else
						error('invalid regex after ' .. sub(regex, 1, bs))
					end
				elseif c == '?' then
					if lastFunc then
						table.insert(matcher.functions, question(lastFunc))
						lastFunc = nil
					else
						error('invalid regex after ' .. sub(regex, 1, bs))
					end
				elseif c == '^' then
					if bs == 1 then
						matcher.fromStart = true
					else
						error('invalid regex after ' .. sub(regex, 1, bs))
					end
				elseif c == '$' then
					if be == len(regex) then
						matcher.toEnd = true
					else
						error('invalid regex after ' .. sub(regex, 1, bs))
					end
				elseif c == '[' then
					if lastFunc then
						table.insert(matcher.functions, simple(lastFunc))
					end
					lastFunc, skip = classMatchGenerator(sub(regex, be + 1))
				elseif c == '(' then
					if lastFunc then
						table.insert(matcher.functions, simple(lastFunc))
						lastFunc = nil
					end
					table.insert(matcher.captures, {})
					table.insert(cs, #matcher.captures)
					table.insert(matcher.functions, captureStart(cs[#cs]))
					if sub(regex, be + 1, be + 1) == ')' then matcher.captures[#matcher.captures].empty = true end
				elseif c == ')' then
					if lastFunc then
						table.insert(matcher.functions, simple(lastFunc))
						lastFunc = nil
					end
					local cap = table.remove(cs)
					if not cap then
						error('invalid capture: "(" missing')
					end
					table.insert(matcher.functions, captureStop(cap))
				elseif c == '.' then
					if lastFunc then
						table.insert(matcher.functions, simple(lastFunc))
					end
					lastFunc = function(cC) return cC ~= -1 end
				elseif c == '%' then
					ignore = true
				else
					if lastFunc then
						table.insert(matcher.functions, simple(lastFunc))
					end
					lastFunc = classMatchGenerator(c)
				end
			end
		end
	end
	if #cs > 0 then
		error('invalid capture: ")" missing')
	end
	if lastFunc then
		table.insert(matcher.functions, simple(lastFunc))
	end
	lastFunc = nil
	ignore = nil
	
	table.insert(matcher.functions, function()
		if matcher.toEnd and matcher.str ~= matcher.stringLen then
			matcher:reset()
		else
			matcher.stop = true
		end
	end)
	
	matcher.nextFunc = function(self)
		self.func = self.func + 1
	end
	matcher.nextStr = function(self)
		self.str = self.str + 1
	end
	matcher.strReset = function(self)
		local oldReset = self.reset
		local str = self.str
		self.reset = function(s)
			s.str = str
			s.reset = oldReset
		end
	end
	matcher.fullResetOnNextFunc = function(self)
		local oldReset = self.reset
		local func = self.func +1
		local str = self.str
		self.reset = function(s)
			s.func = func
			s.str = str
			s.reset = oldReset
		end
	end
	matcher.fullResetOnNextStr = function(self)
		local oldReset = self.reset
		local str = self.str + 1
		local func = self.func
		self.reset = function(s)
			s.func = func
			s.str = str
			s.reset = oldReset
		end
	end
	
	matcher.process = function(self, str, start)
		
		self.func = 1
		start = start or 1
		self.startStr = (start >= 0) and start or utf8len(str) + start + 1
		self.seqStart = self.startStr
		self.str = self.startStr
		self.stringLen = utf8len(str) + 1
		self.string = str
		self.stop = false
		
		self.reset = function(s)
			s.func = 1
		end

		local lastPos = self.str
		local lastByte
		local char
		while not self.stop do
			if self.str < self.stringLen then
				--[[ if lastPos < self.str then
					print('last byte', lastByte)
					char, lastByte = utf8subWithBytes(str, 1, self.str - lastPos - 1, lastByte)
					char, lastByte = utf8subWithBytes(str, 1, 1, lastByte)
					lastByte = lastByte - 1
				else
					char, lastByte = utf8subWithBytes(str, self.str, self.str)
				end
				lastPos = self.str ]]
				char = utf8sub(str, self.str,self.str)
				--print('char', char, utf8unicode(char))
				self.functions[self.func](utf8unicode(char))
			else
				self.functions[self.func](-1)
			end
		end
		
		if self.seqStart then
			local captures = {}
			for _,pair in pairs(self.captures) do
				if pair.empty then
					table.insert(captures, pair[1])
				else
					table.insert(captures, utf8sub(str, pair[1], pair[2]))
				end
			end
			return self.seqStart, self.str - 1, unpack(captures)
		end
	end
	
	return matcher
end

-- string.find
local function utf8find(str, regex, init, plain)
	local matcher = cache[regex] or matcherGenerator(regex, plain)
	return matcher:process(str, init)
end

-- string.match
local function utf8match(str, regex, init)
	init = init or 1
	local found = {utf8find(str, regex, init)}
	if found[1] then
		if found[3] then
			return unpack(found, 3)
		end
		return utf8sub(str, found[1], found[2])
	end
end

-- string.gmatch
local function utf8gmatch(str, regex, all)
	regex = (utf8sub(regex,1,1) ~= '^') and regex or '%' .. regex 
	local lastChar = 1
	return function()
		local found = {utf8find(str, regex, lastChar)}
		if found[1] then
			lastChar = found[2] + 1
			if found[all and 1 or 3] then
				return unpack(found, all and 1 or 3)
			end
			return utf8sub(str, found[1], found[2])
		end
	end
end

local function replace(repl, args)
	local ret = ''
	if type(repl) == 'string' then
		local ignore = false
		local num = 0
		for c in utf8gensub(repl) do
			if not ignore then
				if c == '%' then
					ignore = true
				else
					ret = ret .. c
				end
			else
				num = tonumber(c)
				if num then
					ret = ret .. args[num]
				else
					ret = ret .. c
				end
				ignore = false
			end
		end
	elseif type(repl) == 'table' then
		ret = repl[args[1] or args[0]] or ''
	elseif type(repl) == 'function' then
		if #args > 0 then
			ret = repl(unpack(args, 1)) or ''
		else
			ret = repl(args[0]) or ''
		end
	end
	return ret
end
-- string.gsub
local function utf8gsub(str, regex, repl, limit)
	limit = limit or -1
	local ret = ''
	local prevEnd = 1
	local it = utf8gmatch(str, regex, true)
	local found = {it()}
	local n = 0
	while #found > 0 and limit ~= n do
		local args = {[0] = utf8sub(str, found[1], found[2]), unpack(found, 3)}
		ret = ret .. utf8sub(str, prevEnd, found[1] - 1)
		.. replace(repl, args)
		prevEnd = found[2] + 1
		n = n + 1 
		found = {it()}
	end
	return ret .. utf8sub(str, prevEnd), n 
end
                                                                                          
string.utf8len			= utf8len
string.utf8sub			= utf8sub
string.utf8reverse	= utf8reverse
string.utf8char			= utf8char
string.utf8unicode	= utf8unicode
string.utf8gensub		= utf8gensub
string.utf8unicode	= utf8unicode
string.utf8find			= utf8find
string.utf8match		= utf8match
string.utf8gmatch		= utf8gmatch
string.utf8gsub 		= utf8gsub 

