-- https/github.com/ocornut/imgui.git

local imgui_project = Project:new( "imgui", ProjectTypes.StaticLibrary )

imgui_project:add_files( "*.h" )
imgui_project:add_files( "imgui.cpp" )
imgui_project:add_files( "imgui_draw.cpp" )
imgui_project:add_files( "imgui_widgets.cpp" )
--imgui_project:add_files( "imgui_demo.cpp" )

module:add_include_dir( "." )

module.import_func = function( project, solution )
	project:add_project_dependency( imgui_project )
	solution:add_project( imgui_project )
end
