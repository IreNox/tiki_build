-- https/github.com/erincatto/box2d.git

local box2d_project = Project:new(
	"box2d",
	{ "x86", "x64" },
	{ "Debug", "Release" },
	ProjectTypes.StaticLibrary
)

box2d_project.module.module_type = ModuleTypes.FilesModule

box2d_project:add_files( "include/box2d/*.h" )
box2d_project:add_files( "src/**/*.cpp" )

box2d_project:add_include_dir( "include" )
box2d_project:add_include_dir( "src" )

module:add_include_dir( "include" )

module.import_func = function( project, solution )
	project:add_project_dependency( box2d_project )
	solution:add_project( box2d_project )
end
