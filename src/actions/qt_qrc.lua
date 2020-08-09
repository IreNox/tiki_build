return function( data, config )
	local output_path = path.join( config.build_path, "qt_files", config.project_name )
	local output_file = path.join( output_path, data.output_filename )
	
	if is_build_required( data.source_filename, output_file ) then
		local rcc_exe = path.join( data.qt_dir, "bin\\rcc.exe" )
		local name = path.getbasename( data.source_filename )
		local command_line = rcc_exe .. " \"" .. data.source_filename .. "\" -name " .. name .. " -o \"" .. output_file .. "\""
		
		print( "RCC: " .. path.getname( data.source_filename ) )
		if not os.execute( command_line ) then
			throw( "rcc returned an error" )
		end
	end
end