# tiki_build
Module Extension on top of [Premake5](https://premake.github.io/) with support for external Git and SVN modules

## Getting Started

Place the latest [premake_tb](https://github.com/IreNox/tiki_build/releases/latest/) executable in the root of your repository.

Now create a `premake5.lua` file as for Premake. But instead of Premake's functions use the tiki_build classes like in the following Example:
```
local project = Project:new( "project_name", ProjectTypes.ConsoleApplication )

project:add_files( "src/*.c" )

finalize_default_solution( project )
```

## Modules

You can easily create multiple modules and tiki_build will resolve and combine them together:

- modules/core/core.lua:
```
module:add_include_dir( "include" );
module:add_files( "include/**/*.h" )
module:add_files( "src/*.c" )
```

- modules/io/io.lua:
```
module:add_include_dir( "include" );
module:add_files( "include/**/*.h" )
module:add_files( "src/*.c" )
module:add_dependency( "core" )
```

- premake5.lua:
```
add_module_include_path( "modules" )

local project = Project:new( "module_sample", ProjectTypes.ConsoleApplication )
project:add_files( "src/main.c" )
project:add_dependency( "io" )

finalize_default_solution( project )
```

This sample Project will contain all include and source files from `core` and `io` module plus the `main.c`. The dependency tree will be resolved automatically. Also creates unity build files for every module to speed up build times.

## Externals

To import external modules from Git use the `add_external` function. For Reprositories that already have a `tiki.lua` nothing more is todo. Otherwise create a import script in your repository with the following rule. Prepend `externals/` and remove `:/` from URL to get the path:

`https://github.com/nlohmann/json.git` goes to `external/https/github.com/nlohmann/json.git/tiki.lua`

An external module behaves like a normal module. You can get additional information about the external from a local variable called: `tiki.external`.

tiki_build provides some built-in externals:
- https://github.com/erincatto/box2d.git
- https://github.com/kimperator/T-Rex.git
- https://github.com/leethomason/tinyxml2.git
- https://github.com/libsdl-org/SDL.git
- https://github.com/nigels-com/glew.git
- https://github.com/nothings/stb.git
- https://github.com/ocornut/imgui.git
- https://www.sqlite.org
