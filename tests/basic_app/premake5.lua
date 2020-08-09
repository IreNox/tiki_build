-- tests/basic_app

local project = Project:new(
	"basic_app_test",
	{ "x32", "x64" },
	{ "Debug", "Release" },
	ProjectTypes.ConsoleApplication
);

project:add_files( 'src/*.cpp' )

finalize_default_solution( project )
