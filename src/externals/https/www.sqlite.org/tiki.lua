-- https://www.sqlite.org

-- version format: yyyy-Mmmpp00
-- y - year
-- M - major version
-- m - minor version
-- p - patch version

if tiki.external.version == "latest" then
	local response_tags, result_code = http.get( "https://api.github.com/repos/sqlite/sqlite/tags" )
	local response_tags_json =  json.decode( response_tags )

	local response_commit, result_code = http.get( response_tags_json[ 1 ].commit.url )
	local response_commit_json =  json.decode( response_commit )
	local year = response_commit_json.commit.author.date:sub( 0, 4 )

	local tag_name = response_tags_json[ 1 ].name
	local major, minor, patch = tag_name:match( "(%d+).(%d+).(%d+)")
	
	tiki.external.version = string.format( "%04d-%d%02d%02d00", year, major, minor, patch )
end

-- url example: https://sqlite.org/2020/sqlite-amalgamation-3330000.zip

local year, version = tiki.external.version:match( "(%d+)-(%d+)")
local version_name = "sqlite-amalgamation-" .. version
local file_name = version_name .. ".zip"
local download_path = path.join( tiki.external.export_path, file_name )

if not os.isfile( download_path ) then
	local download_url = "https://www.sqlite.org/" .. year .. "/" .. file_name

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

local sqlite_project = Project:new( "sqlite", ProjectTypes.StaticLibrary )

sqlite_project.module.module_type = ModuleTypes.FilesModule

sqlite_project:add_files( version_name .. "/*.h" )
sqlite_project:add_files( version_name .. "/*.c" )

module:add_include_dir( version_name )

module.import_func = function( project, solution )
	project:add_project_dependency( sqlite_project )
	solution:add_project( sqlite_project )
end
