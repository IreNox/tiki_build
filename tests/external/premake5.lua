-- tests/external

--dofile( "../../tiki_build.lua" )

local project = Project:new(
	"external_test",
	{ "x32", "x64" },
	{ "Debug", "Release" },
	ProjectTypes.ConsoleApplication
);

project:add_files( 'src/*.cpp' )

project:add_external( "https://github.com/kimperator/T-Rex.git" )
project:add_external( "https://github.com/leethomason/tinyxml2.git" )
project:add_external( "https://github.com/nothings/stb.git" )
project:add_external( "https://github.com/ocornut/imgui.git" )
project:add_external( "https://github.com/erincatto/box2d.git" )
project:add_external( "git://git.sv.nongnu.org/freetype/freetype2.git" )

finalize_solution( project )
