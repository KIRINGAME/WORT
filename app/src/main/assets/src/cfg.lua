
local cfg = {}

function cfg.read( file )
    local t = util.readfile(file)
    if t == nil then
        cfg[file] = {}
    else
        cfg[file] = table.fromjson(t)
    end
    return cfg[file]
end
function cfg.save( file , data )
    if data ~= nil then 
        cfg[file] = data 
    end
    if cfg[file] == nil then
        cfg[file] = {}
    end
    util.savefile(file,table.tojson(cfg[file]))
end
function cfg.get(file,key)
   local t = cfg.read(file)
   return t[key]
end
function cfg.set(file,key,value)    
    if file == nil or key == nil or value == nil then
        return 
    end
    if cfg[file] == nil then
        cfg[file] = {}
    end
    cfg[file][key] = value
    cfg.save( file )
end

_G["cfg"] = cfg

return cfg