local util = {}
_G.util = util
function util.readfile( file_path )
    local contents, size = love.filesystem.read( file_path )
    return contents,size
end
function util.savefile( file_path, data)
    local dir = ""
    for i in (string.gmatch(file_path,[[(.-)/]])) do
        if #i >0 then
            dir = dir .. "/" .. i
        end
    end
    love.filesystem.createDirectory( dir )

    local data = tostring(data)
    local size = data:length()
    local success,message = love.filesystem.write( file_path, data, size)
    return success,message
end

function util.appendfile( file_path, data)
    local dir = ""
    for i in (string.gmatch(file_path,[[(.-)/]])) do
        if #i >0 then
            dir = dir .. "/" .. i
        end
    end
    love.filesystem.createDirectory( dir )
    
    local data = tostring(data)
    local size = data:length()
    local success,message = love.filesystem.append( file_path, data, size)
    return success,message
end

function util.deletefile(path_file)
    love.filesystem.remove(path_file)
end

return util