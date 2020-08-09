return function( data, config )
	local output_path = path.join( config.build_path, "qt_files", config.project_name )
	local output_file = path.join( output_path, data.output_filename )

	if is_build_required( data.source_filename, output_file ) then
		local moc_exe = path.join( data.qt_dir, "bin\\moc.exe" )
		local moc_defines = "-D_WINDOWS -DUNICODE -DWIN32 -DWIN64 -DQT_WIDGETS_LIB -DQT_GUI_LIB -DQT_CORE_LIB"
		
		local moc_include_dirs = {
			path.join( data.qt_dir, "include" ),
			path.join( data.qt_dir, "include\\QtWidgets" ),
			path.join( data.qt_dir, "include\\QtGui" ),
			path.join( data.qt_dir, "include\\QtCore" )
		}
		
		local moc_includes = "-I" .. table.concat( moc_include_dirs," -I" )
		local command_line = moc_exe .. " \"" .. data.source_filename .. "\" -o \"" .. output_file .. "\" " .. moc_defines .. " " .. moc_includes

		print( "MOC: " .. path.getname( data.source_filename ) )
		if not os.execute( command_line ) then
			throw( "moc return an error" )
		end
	end
end