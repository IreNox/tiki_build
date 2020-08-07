@echo off
..\..\genie.exe /to=build/vs2019 vs2019

cd build/vs2019
msbuild basic_app.sln -p:Configuration=Release -p:Platform=x86
