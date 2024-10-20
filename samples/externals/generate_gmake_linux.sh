#/bin/bash

../../premake5 --systemscript=../../tiki_build.lua --to=build/gmake_linux --os=linux --cc=gcc gmake
if [ $? -ne 0 ]; then
  echo "Press any key to continue..."
  read -n 1
fi
