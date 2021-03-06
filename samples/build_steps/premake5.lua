-- tests/build_steps

local project = Project:new( "build_steps_test", ProjectTypes.ConsoleApplication )

project:add_files( "src/*.c" )

project:add_post_build_step( "copy_file", { source = "src/copy.txt" } )
project:add_post_build_step( "copy_files", { pattern = "content/**" } )

finalize_default_solution( project )
