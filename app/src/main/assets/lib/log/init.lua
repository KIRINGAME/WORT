local log = {}
function log.output( ... )
    print(...)
	do return end
	local osString = love.system.getOS( )
	if osString ~= "Android" and osString ~= "iOS" then
        local fw = io.open("log.txt", "a")
        if nil == fw then
            os.exit(0)
        end
        fw:write(...)
        fw:write("\n")
        fw:close()
	end
end
function log.error( ... )
	local osString = love.system.getOS( )
	if osString ~= "Android" and osString ~= "iOS" then
        print("<Error>"..(...))
	end
end
_G.log = log.output
return log