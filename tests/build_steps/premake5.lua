-- tests/build_steps

local project = Project:new(
	"build_steps_test",
	{ "x32", "x64" },
	{ "Debug", "Release" },
	ProjectTypes.ConsoleApplication
);

project:add_files( "src/*.cpp" )

project:add_post_build_step( "copy_file", { source = "src/copy.txt" } )

finalize_default_solution( project )
