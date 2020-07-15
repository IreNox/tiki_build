-- git/github.com/erincatto/box2d

local box2d_project = Project:new(
	"box2d_lib",
	{ "x32", "x64" },
	{ "Debug", "Release" },
	ProjectTypes.StaticLibrary
);

box2d_project:set_base_path( external.export_path )

box2d_project.module.module_type = ModuleTypes.FilesModule;

box2d_project:add_files( "include/box2d/*.h" );
box2d_project:add_files( "src/**/*.cpp" );

box2d_project:add_include_dir( "include" );
box2d_project:add_include_dir( "src" );

local module = Module:new( "box2d" );

module:set_base_path( external.export_path )

module:add_library_file( "box2d_lib" );

module:add_include_dir( "include" );

module.import_func = function( project, solution )
	solution:add_project( box2d_project );
end

return module