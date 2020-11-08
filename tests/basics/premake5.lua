-- tests/basics

local project = Project:new( "basics_test", ProjectTypes.ConsoleApplication )
project:add_files( 'src/*.c' )

finalize_default_solution( project )
