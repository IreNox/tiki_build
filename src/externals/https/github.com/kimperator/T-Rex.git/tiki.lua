-- https/github.com/kimperator/T-Rex.git

local trex_project = Project:new(
	"trex",
	{ "x32", "x64" },
	{ "Debug", "Release" },
	ProjectTypes.StaticLibrary
);

trex_project.module.module_type = ModuleTypes.FilesModule;

trex_project:add_files( "*.h" );
trex_project:add_files( "trex.c" );

module:add_include_dir( "." );

module.import_func = function( project, solution )
	project:add_project_dependency( trex_project )
	solution:add_project( trex_project );
end