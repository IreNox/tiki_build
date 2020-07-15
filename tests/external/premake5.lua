-- tests/external

--dofile( "../../tiki_build.lua" )

local project = Project:new(
	"external_test",
	{ "x32", "x64" },
	{ "Debug", "Release" },
	ProjectTypes.ConsoleApplication
);

project:add_files( 'src/*.cpp' )

project:add_external( "git:github.com/erincatto/box2d" )

finalize_solution( project )
