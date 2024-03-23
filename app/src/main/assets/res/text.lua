
local text = {}
text.__index = text

text.text = 
{
    [1] = {"     LEVEL UP",          "Level-Up-Herausforderung"},
    [2] = {"  DAILY WORD",      "tägliche Herausforderungen"},
    [3] = {"View this ad to get 100 coins, which can be used for tips.",      "Sehen Sie diese Anzeige, um 100 Goldmünzen zu erhalten Als Hinweis"},
    [4] = {"At least 10 coins are needed.",          "Mindestens 10 Münzen"},
    [5] = {"Costs 10 coins.",      "10 Münzen ausgegeben"},
    [6] = {"The task is completed today.",      "Heute ist alles erledigt"},
    [7] = {"yes",      "gut"},
    [8] = {"no",      "Nein"},
    [9] = {"unlock word",      "Entsperrtes Wort"},
    [10] = {"extra word",      "Extra Wörter"},
 }

function text:init( ... )
    self.cfg = 1
    return self
end
function text:set_cfg( cfg )
    self.cfg = cfg
end
function text:get( text_id )
    return self.text[tonumber(text_id)][self.cfg]
end
_G["text"] = text:init()
