@ECHO off

set loveinstalldir="%PROGRAMFILES%\LOVE"

cd .\src

7z a ..\temp.zip .

cd ..

xcopy %loveinstalldir% build /I /Y /Q
cd .\build
del /Q love.ico lovec.exe readme.txt Uninstall.exe game.ico changes.txt

move ..\temp.zip .\snek.love
copy /b love.exe+snek.love snek.exe
del /Q love.exe snek.love

7z a ..\snek.zip .

cd ..
del /S /Q build