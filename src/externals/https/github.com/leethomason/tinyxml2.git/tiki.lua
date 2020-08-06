-- https/github.com/leethomason/tinyxml2.git

local tinyxml_project = Project:new(
	"tinyxml2",
	{ "x32", "x64" },
	{ "Debug", "Release" },
	ProjectTypes.StaticLibrary
);

--module.module_type = ModuleTypes.FilesModule;

tinyxml_project:add_files( "tinyxml2.h" );
tinyxml_project:add_files( "tinyxml2.cpp" );

module:add_library_file( "tinyxml2" );
module:add_include_dir( "." );

module.import_func = function( project, solution )
	solution:add_project( tinyxml_project );
end