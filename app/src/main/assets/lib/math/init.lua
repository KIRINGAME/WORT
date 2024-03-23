function math.pointinrect( x,y,left_up_x,left_up_y,w,h )
    if x >= left_up_x and x <= left_up_x + w and y >= left_up_y and y<= left_up_y + h then
        return true
    else
        return false
    end
end
function math.distance(x1,y1,x2,y2)
    local x = x2 - x1
    local y = y2 - y1
    return math.sqrt(x*x+y*y)
end

-- 与操作
function math.op_and(num1,num2)
	local tmp1 = num1
	local tmp2 = num2
	local str = ""
	repeat
		local s1 = tmp1 % 2
		local s2 = tmp2 % 2
		if s1 == s2 then
			if s1 == 1 then
				str = "1"..str
			else
				str = "0"..str
			end
		else
			str = "0"..str
		end
		tmp1 = math.modf(tmp1/2)
		tmp2 = math.modf(tmp2/2)
	until(tmp1 == 0 and tmp2 == 0)
	return tonumber(str,2)
end

-- 右移num位
function math.op_rshift(right,num)
    return math.floor(right / (2 ^ num))
end

-- 左移num位
function math.op_lshift(left,num)
    if num > 31 or num < 0 then
        return 0
    else
        return math.floor(left * (2 ^ num))
    end
end
