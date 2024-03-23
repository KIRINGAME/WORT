
----------------------------------------------------------------------------

----------------------------------------------------------------------------
function love.conf(win)
    win.identity = "DeutscherOrden" 
	win.title = "DeutscherOrden"
	win.window.fullscreentype = "desktop"
	win.window.highdpi = true
	-- win.window.msaa = 1

	-- 6.5寸
	-- win.window.width = 428--1284/3--
	-- win.window.height = 926--2778/3--

    -- iPad air 5rd 10.9寸
    -- win.window.width = 410--1640 /4--
    -- win.window.height = 590--2360/4--
	-- -- -- 5.5寸
	win.window.width = 414--1242/3--
	win.window.height = 736--2208/3--
	
	-- -- 12.9寸
	-- win.window.width = 512--2048/4--
	-- win.window.height = 683--2732/4--
end