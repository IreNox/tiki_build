-- tests/local_external

local project = Project:new(
	"local_external_test",
	{ "x86", "x64" },
	{ "Debug", "Release" },
	ProjectTypes.ConsoleApplication
);

project:add_files( 'src/*.c' )

project:add_external( "local://my_external" )

finalize_default_solution( project )
