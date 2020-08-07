# Tiki Build
Module Extension on top of Premake5 with support for external Git and SVN modules

## Getting Started

Place the executable of [Premake5](https://premake.github.io/download.html) and the latest version of [tiki_build.lua](https://github.com/IreNox/tiki_build/releases/latest/download/tiki_build.lua) in the root of your repository.

Like in Premake create a `premake5.lua` file. But instead of premake's functions use the tiki_build classes in like this Example:
```
local project = Project:new(
	"project_name",
	{ "x32", "x64" },		-- platforms
	{ "Debug", "Release" },		-- configurations
	ProjectTypes.ConsoleApplication
);

project:add_files( 'src/*.cpp' )

finalize_solution( project )
```