-- development entry point
-- loads all scripts

local script_path = path.getabsolute( path.getdirectory( _SCRIPT ) )

tiki = {
	root_path = path.getabsolute( script_path )
}

local manifest  = dofile( script_path .. "/_manifest.lua" )

for _, file in ipairs( manifest.embeded ) do
	dofile( script_path .. "/" .. file )
end
