-- generate single file

local script_path = path.getdirectory( _SCRIPT )

local function load_and_strip_file(fname, in_string)
	local f = io.open(fname)
	local s = assert(f:read("*a"))
	f:close()

	-- strip tabs
	s = s:gsub("[\t]", "")
	
	-- strip any CRs
	s = s:gsub("[\r]", "")
	
	-- strip out comments
	s = s:gsub("\n%-%-[^\n]*", "")
			
	-- strip duplicate line feeds
	s = s:gsub("\n+", "\n")

	-- strip out leading comments
	s = s:gsub("^%-%-\n", "")
	
	if in_string then
		-- escape double quote marks
		s = s:gsub("\\\"", "\\\\\"")

		-- escape double quote marks
		s = s:gsub("\"", "\\\"")

		-- escape line feeds
		s = s:gsub("\n", "\\n\" ..\n\"")
	end

	return s
end

function do_release()
	local manifest = dofile( path.join( script_path, "../src/_manifest.lua" ) )
	
	local output_file = io.open( path.join( script_path, "../tiki_build.lua" ), "w" )
	
	output_file:write("-- Tiki Build Lua scripts, pack togther as a single file\n")
	output_file:write("-- DO NOT EDIT - this file is autogenerated - see README.md\n")
	output_file:write("-- To regenerate this file, run: premake5 release\n\n")

	local source_path = path.join( script_path, "../src" )
	for _, file in ipairs( manifest.embeded ) do
		print( "Embed: " .. file )

		local file_path = path.join( source_path, file )
		local file_content = load_and_strip_file( file_path, false )
		output_file:write( "-- " .. file .."\n" )
		output_file:write( file_content )
		output_file:write( "\n" )
	end
	
	for _, pattern in ipairs( manifest.dynamic ) do
		local matches = os.matchfiles( path.join( source_path, pattern ) )
		
		for _, file_path in ipairs( matches ) do
			local file = path.getrelative( source_path, file_path )
		
			print( "Dynamic: " .. file )

			local file_content = load_and_strip_file( file_path, true )
			output_file:write( "-- " .. file .."\n" )
			output_file:write( "tiki.files[ \"" .. file .. "\" ] = \"" .. file_content )
			output_file:write( "\"\n" )
		end
	end
	
	output_file:close()
end