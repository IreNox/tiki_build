-- Action to install files into a output folder

-- Step Data
-- pattern	pattern of files to install
-- target	target path

return function( data, config )
	local files = os.matchfiles( path.join( config.output_path, data.pattern ) )
	local target_path = path.join( config.base_path, data.target )

	for _,file in pairs( files ) do
		if is_build_required( file, target_path ) then
			print( "Install " .. path.getname( file ) .. " to " .. target_path )
			
			local target_file = path.join( target_path, path.getname( file ) )
			local ok, err = os.copyfile( file, target_file )
			if not ok then
				throw( "Failed to install " .. file .. ". Error: " .. err )
			end
		end
	end
end