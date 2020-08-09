return function( data, config )
	local matches = os.matchfiles( data.source_pattern )

	if #matches == 0 then
		throw("[qt] '" .. data.source_pattern .. "' pattern matches no files.")
	end
	
	local content = {}
	table.insert( content, "<!DOCTYPE RCC>" )
	table.insert( content, "<RCC version=\"1.0\">" )
	table.insert( content, "\t<qresource prefix=\"" .. data.prefix .. "\">" )		
	for j, filename in pairs( matches ) do
		local alias = path.getname( filename )
		table.insert( content, "\t\t<file alias=\"" .. alias .. "\">" .. filename .. "</file>" )
	end
	table.insert( content, "\t</qresource>" )
	table.insert( content, "</RCC>" )
	
	local content_string = table.concat( content, "\n" )
	local current_content = io.readfile( data.output_filename )
	if content_string ~= current_content then
		print( "Generate RCC: " .. path.getname( data.output_filename ) )
		io.writefile( data.output_filename, content_string )
	end
end
