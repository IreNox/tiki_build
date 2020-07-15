@echo off
..\..\premake5.exe --verbose /systemscript=../../tiki_build.lua /to=build/vs2017 vs2017
if errorlevel 1 goto error

cd build/vs2017
rem msbuild basic_app.sln -p:Configuration=Release -p:Platform=x86
cd ../..

:error