-- tests/local_external

local project = Project:new( "local_external_test", ProjectTypes.ConsoleApplication )

project:add_files( 'src/*.c' )

project:add_external( "local://my_external1" )
project:add_external( "local://my_external2" )

finalize_default_solution( project )
