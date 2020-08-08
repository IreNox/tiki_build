-- https/sourceforge.net/projects/libpsd

local version_name = "libpsd-0.9"
local download_path = path.join( tiki.external.export_path, "source_code.zip" )

if not os.isfile( download_path ) then
	local download_url = "https://downloads.sourceforge.net/project/libpsd/libpsd/0.9/libpsd-0.9.zip"

	print( "Download: " .. download_url )
	local result_str, result_code = http.download( download_url, download_path )
	if result_code ~= 200 then
		throw( "libpsd download failed with error " .. result_code .. ": " .. result_str )
	end
	
	zip.extract( download_path, tiki.external.export_path )
end

local libpsd_project = Project:new(
	"libpsd",
	{ "x32", "x64" },
	{ "Debug", "Release" },
	ProjectTypes.StaticLibrary
);

libpsd_project.module.module_type = ModuleTypes.FilesModule;

libpsd_project:add_include_dir( version_name .. "/include" );
libpsd_project:add_files( version_name .. "/include/*.h" );
libpsd_project:add_files( version_name .. "/src/*.h" );
libpsd_project:add_files( version_name .. "/src/*.c" );

module:add_library_file( "libpsd" );
module:add_include_dir( version_name .. "/include" );

module.import_func = function( project, solution )
	solution:add_project( libpsd_project );
end


