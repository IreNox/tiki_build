-- development entry point
-- loads all scripts

local script_path = path.getabsolute( path.getdirectory( _SCRIPT ) )

tiki = {
	root_path = path.getabsolute( script_path )
}

local scripts  = dofile( script_path .. "/_manifest.lua" )
for _, script in ipairs( scripts ) do
	dofile( script_path .. "/" .. script )
end
