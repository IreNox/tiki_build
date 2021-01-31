-- tests/externals

local project = Project:new( "externals_test", ProjectTypes.ConsoleApplication )

project:add_files( 'src/*.c' )

project:add_external( "https://github.com/kimperator/T-Rex.git" )
project:add_external( "https://github.com/leethomason/tinyxml2.git" )
project:add_external( "https://github.com/nothings/stb.git" )
project:add_external( "https://github.com/ocornut/imgui.git" )
project:add_external( "https://github.com/erincatto/box2d.git" )

finalize_default_solution( project )
