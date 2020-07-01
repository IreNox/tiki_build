-- tests/basic_app

dofile( "../../tiki_build.lua" )

local project = Project:new(
	"box2d_test",
	{ "x32", "x64" },
	{ "Debug", "Release" },
	ProjectTypes.WindowApplication
);

project:add_files( 'src/*.cpp' )

project:add_external( "git:github.com/erincatto/box2d" )

finalize_solution( project )
