return function( data, config )
	local files = os.matchfiles( path.join( config.output_path, data.pattern ) )
	local target_path = path.join( global_configuration.root_path, data.target );

	for _,file in pairs( files ) do
		if is_build_required( file, target_path ) then
			print( "Install " .. path.getname( file ) .. " to " .. target_path );
			os.copyfile( file, target_path );
		end
	end
end