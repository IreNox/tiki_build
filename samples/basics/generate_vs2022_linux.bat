@echo off
..\..\premake5.exe --systemscript=../../tiki_build.lua --to=build/vs2022_linux --os=linux vs2022
EXIT /B %ERRORLEVEL%
