
local sound = {}
sound.music_stopped = false
sound.sound_stopped = false
sound.music_name=""

function sound.init( ... )
    
	local sound_cfg = {
		music           = {"res/sound/melody_of_the_night.mp3"  , "stream"},
		click           = {"res/sound/click.wav"                , "static"},
		hint            = {"res/sound/hint.wav"                 , "static"},
		tips            = {"res/sound/tips.wav"                 , "static"},
		win             = {"res/sound/win.wav"                  , "static"},
		gold            = {"res/sound/gold.mp3"                 , "static"},
		get_word        = {"res/sound/get_word.ogg"             , "static"},
		click_letter_1  = {"res/sound/click_letter_1.ogg"       , "static"},
		click_letter_2  = {"res/sound/click_letter_2.ogg"       , "static"},
		click_letter_3  = {"res/sound/click_letter_3.ogg"       , "static"},
		click_letter_4  = {"res/sound/click_letter_4.ogg"       , "static"},
		click_letter_5  = {"res/sound/click_letter_5.ogg"       , "static"},
		click_letter_6  = {"res/sound/click_letter_6.ogg"       , "static"},
		click_letter_7  = {"res/sound/click_letter_7.ogg"       , "static"}
    }
    sound.t = {}
    for k,v in pairs(sound_cfg) do
        sound.t[k] = love.audio.newSource( v[1],v[2] )
    end
end
function sound.play_music(name,volume)
    sound.music_name = name
    if sound.music_stopped then return end
    if sound.t and sound.t[name] then
        if volume ~= nil then
            sound.t[name]:setVolume(volume)
        end
        sound.t[name]:play()
        sound.t[name]:setLooping(true)
    end
end
function sound.play( name ,volume)
    if sound.sound_stopped then return end
    if sound.t and sound.t[name] then
        if volume ~= nil then
            sound.t[name]:setVolume(volume)
        end
        sound.t[name]:play()
    end
end
function sound.set_volume( name,volume )
    if sound.t and sound.t[name] then
        sound.t[name]:setVolume(volume)
    end
end
function sound.set_looping( loop )
    if sound.t and sound.t[name] then
        sound.t[name]:setLooping(loop)
    end
end

function sound.stop_music()
    sound.music_stopped = true
    if sound.t and sound.t[sound.music_name] then
        sound.t[sound.music_name]:stop()
    end
end
function sound.stop_sound()
    sound.sound_stopped = true
end

_G["sound"] = sound

return sound