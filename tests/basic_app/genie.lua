-- tests/basic_app

dofile( "../../tiki_build.lua" )

local project = Project:new(
	"basic_app",
	{ "x32", "x64" },
	{ "Debug", "Release" },
	ProjectTypes.WindowApplication
);

project:add_files( 'src/*.cpp' )

finalize_solution( project )
