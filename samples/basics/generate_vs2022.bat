@echo off
..\..\premake5.exe --systemscript=../../tiki_build.lua --to=build/vs2022 vs2022
EXIT /B %ERRORLEVEL%
