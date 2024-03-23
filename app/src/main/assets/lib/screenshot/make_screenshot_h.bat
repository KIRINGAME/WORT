@@ -1,6 +0,0 @@
::https://imagemagick.org/script/download.php
::https://imagemagick.org/script/command-line-processing.php
c:
cd "C:\Documents and Settings\Administrator\Application Data\LOVE\lovegame\screenshot\"

makedir target
cd target
md 5.5
md 6.5
md 12.9
magick convert "C:\Documents and Settings\Administrator\Application Data\LOVE\lovegame\screenshot\source\6.5\*.png" -resize 2778x1284 "C:\Documents and Settings\Administrator\Application Data\LOVE\lovegame\screenshot\target\6.5\1.jpg"
magick convert "C:\Documents and Settings\Administrator\Application Data\LOVE\lovegame\screenshot\source\5.5\*.png" -resize 2208x1242 "C:\Documents and Settings\Administrator\Application Data\LOVE\lovegame\screenshot\target\5.5\1.jpg"
magick convert "C:\Documents and Settings\Administrator\Application Data\LOVE\lovegame\screenshot\source\12.9\*.png" -resize 2732x2048 "C:\Documents and Settings\Administrator\Application Data\LOVE\lovegame\screenshot\target\12.9\1.jpg"
