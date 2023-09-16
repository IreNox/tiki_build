-- tests/externals

local project = Project:new( "recursive_externals_test", ProjectTypes.WindowApplication )

project:add_files( 'src/*.c' )

project:add_external( "https://github.com/IreNox/imapp.git" )

project:execute_build_step( "test", { bla = 7, xxx = "Wurst" } )

finalize_default_solution( project )
