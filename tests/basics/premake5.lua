-- tests/basics

local project = Project:new(
	"basics_test",
	{ "x86", "x64" },
	{ "Debug", "Release" },
	ProjectTypes.ConsoleApplication
);

project:add_files( 'src/*.c' )

finalize_default_solution( project )
