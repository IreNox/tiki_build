-- Action to copy a file into output folder

-- Step Data
-- source	path of file to copy
-- target	optional target name in output path

return function( data, config )
	local source_path = path.join( config.base_path, data.source )
	if not os.isfile( source_path ) then
		throw( "[copy_binary] Source file not found at " .. data.source )
	end
	
	if not data.target then
		data.target = path.getname( data.source )
	end
	
	local target_path = path.join( config.output_path, data.target )
	if is_build_required( source_path, target_path ) then
		print( "Copy " .. data.source .. " to output directory" )
		os.copyfile( source_path, target_path )
	end
end