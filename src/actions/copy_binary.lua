return function( data, config )
	if not os.isfile( data.source ) then
		throw( "[copy_binary] Source file not found at " .. data.source )
	end
	
	local target_path = path.join( config.output_path, data.target );
	if is_build_required( data.source, target_path ) then
		print( "Copy " .. data.source .. " to output directory" );
		os.copyfile( data.source, target_path );
	end
end