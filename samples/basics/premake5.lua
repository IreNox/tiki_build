-- tests/basics

local project = Project:new( "basics_test", ProjectTypes.ConsoleApplication )
project:add_files( 'src/*.h' )
project:add_files( 'src/*.c' )
project:add_files( 'src/*.cpp' )

finalize_default_solution( project )
