-- Action to copy files into output folder

-- Step Data
-- pattern	pattern of files to copy
-- target	optional target path in output directory

return function( data, config )
	local pattern = path.join( config.base_path, data.pattern );
	local files = os.matchfiles( pattern )
	if #files == 0 then
		throw( "[copy_files] No source files found for " .. pattern )
	end

	local target_path = config.output_path
	if data.target then
		target_path = path.join( config.output_path, data.target )
	end
	
	for _,file in ipairs( files ) do
		local relative_path = path.getrelative( config.base_path, file )
		local target_file = path.join( target_path, relative_path )
		
		if is_build_required( file, target_file ) then
			local target_dir = path.getdirectory( target_file )
			if not os.isdir( target_dir ) then
				quiet( "Create " .. target_dir .. " directory" )
				os.mkdir( target_dir )
			end
		
			quiet( "Copy " .. path.getname( target_file ) .. " to output directory" )
			os.copyfile( file, target_file )
		end
	end
end