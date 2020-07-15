-- tests/basic_app

dofile( "../../tiki_build.lua" )

local project = Project:new(
	"basic_app_test",
	{ "x32", "x64" },
	{ "Debug", "Release" },
	ProjectTypes.ConsoleApplication
);

project:add_files( 'src/*.cpp' )

finalize_solution( project )
