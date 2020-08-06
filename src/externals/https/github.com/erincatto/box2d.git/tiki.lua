-- https/github.com/erincatto/box2d.git

local box2d_project = Project:new(
	"box2d",
	{ "x32", "x64" },
	{ "Debug", "Release" },
	ProjectTypes.StaticLibrary
);

--box2d_project:set_base_path( external.export_path )

box2d_project.module.module_type = ModuleTypes.FilesModule;

box2d_project:add_files( "include/box2d/*.h" );
box2d_project:add_files( "src/**/*.cpp" );

box2d_project:add_include_dir( "include" );
box2d_project:add_include_dir( "src" );

module:add_library_file( "box2d" );
module:add_include_dir( "include" );

module.import_func = function( project, solution )
	solution:add_project( box2d_project );
end
