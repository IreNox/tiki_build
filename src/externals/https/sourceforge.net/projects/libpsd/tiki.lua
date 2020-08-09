-- https/sourceforge.net/projects/libpsd

local version_name = "libpsd-0.9"
local download_path = path.join( tiki.external.export_path, "source_code.zip" )

if not os.isfile( download_path ) then
	local download_url = "https://downloads.sourceforge.net/project/libpsd/libpsd/0.9/libpsd-0.9.zip"

	print( "Download: " .. download_url )
	local result_str, result_code = http.download( download_url, download_path )
	if result_code ~= 200 then
		os.remove( download_path );
		throw( "libpsd download failed with error " .. result_code .. ": " .. result_str )
	end
	
	if not zip.extract( download_path, tiki.external.export_path ) then
		os.remove( download_path );
		throw( "Failed to extract libPSD." )
	end

	
	local source_config_path = path.join( path.getdirectory( _SCRIPT ), "psd_config.h" )
	local target_config_path = path.join( tiki.external.export_path, "libpsd-0.9/include/psd_config.h" )
	os.chmod( target_config_path, "777" )
	assert( os.copyfile( source_config_path, target_config_path ) )
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

module:add_include_dir( version_name .. "/include" );

module.import_func = function( project, solution )
	project:add_project_dependency( libpsd_project )
	solution:add_project( libpsd_project );
end


