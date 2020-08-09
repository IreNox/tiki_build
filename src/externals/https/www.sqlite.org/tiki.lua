-- https/sqlite.org

local version_name = "sqlite-amalgamation-" .. tiki.external.version
local download_path = path.join( tiki.external.export_path, "source_code.zip" )

if not os.isfile( download_path ) then
	local download_url = "https://www.sqlite.org/2020/" .. version_name .. ".zip"

	print( "Download: " .. download_url )
	local result_str, result_code = http.download( download_url, download_path )
	if result_code ~= 200 then
		os.remove( download_path )
		throw( "SQLite download failed with error " .. result_code .. ": " .. result_str )
	end
	
	if not zip.extract( download_path, tiki.external.export_path ) then
		os.remove( download_path )
		throw( "Failed to extract SQLite" )
	end
end

local sqlite_project = Project:new(
	"sqlite",
	{ "x32", "x64" },
	{ "Debug", "Release" },
	ProjectTypes.StaticLibrary
)

sqlite_project.module.module_type = ModuleTypes.FilesModule

sqlite_project:add_files( version_name .. "/*.h" )
sqlite_project:add_files( version_name .. "/*.c" )

module:add_include_dir( version_name )

module.import_func = function( project, solution )
	project:add_project_dependency( sqlite_project )
	solution:add_project( sqlite_project )
end
