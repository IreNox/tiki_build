@echo off
..\..\premake5.exe --systemscript=../../tiki_build.lua --to=build/vs2017 vs2017
EXIT /B %ERRORLEVEL%
