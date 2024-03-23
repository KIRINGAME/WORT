local screenshot = {}
function screenshot.keypressed(key, scancode, isrepeat )
    if key == "f8" then       
        print("screen shot")
        love.graphics.captureScreenshot(
            function (imgdata)
                local w = imgdata:getWidth()
                local h = imgdata:getHeight()
                if (w == 428 and h ==  926) or (h == 428 and w ==  926) then
                    love.filesystem.createDirectory("screenshot/source/6.5")
                    imgdata:encode("png","screenshot/source/6.5/"..os.time()..".png")
                elseif (w == 414 and h ==  736) or (h == 414 and w ==  736) then
                    love.filesystem.createDirectory("screenshot/source/5.5")
                    imgdata:encode("png","screenshot/source/5.5/"..os.time()..".png")
                elseif (w == 512 and h ==  683) or (h == 512 and w ==  683) then
                    love.filesystem.createDirectory("screenshot/source/12.9")
                    imgdata:encode("png","screenshot/source/12.9/"..os.time()..".png")
                else
                    love.filesystem.createDirectory("screenshot/source/")
                    imgdata:encode("png","screenshot/source/"..os.time()..".png")

                end 
            end
        )
    end
end
_G["screenshot"] = screenshot
return screenshot