@echo off
..\..\premake5.exe --systemscript=../../tiki_build.lua --to=build/vs2019_android --os=android vs2019
EXIT /B %ERRORLEVEL%
