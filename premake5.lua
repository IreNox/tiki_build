
--
-- Use the release action to generate a single file containing all Lua scripts.
--

if tiki then
	print( tiki.root_path )
	print( tiki.executable_included )
end

dofile( "scripts/build.lua" )
dofile( "scripts/generate.lua" )

