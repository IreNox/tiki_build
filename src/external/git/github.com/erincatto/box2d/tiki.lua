-- git/github.com/erincatto/box2d

local project = Project:new(
	"box2d",
	{ "x32", "x64" },
	{ "Debug", "Release" },
	ProjectTypes.StaticLibrary
);

project.module.module_type = ModuleTypes.FilesModule;

project:add_files( "include/box2d/*.h" );
project:add_files( "src/**/*.cpp" );

project:add_include_dir( "include" );
project:add_include_dir( "src" );
