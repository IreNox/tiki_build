newoption { trigger = "to", description = "Location for generated project files" }

if _ACTION ~= "targets" and not _OPTIONS[ "to" ] then
	error( "No 'to' option specified." );
end

global_configuration = {
	scripts_path = path.getabsolute( path.getdirectory( _SCRIPT ) ),
	root_path = path.getabsolute( path.join( path.getdirectory( _SCRIPT ), "../../.." ) ),
	genie_path = path.getabsolute( path.join( path.getdirectory( _SCRIPT ), '../genie/genie.exe' ) )
};

dofile( "third_party/datadumper.lua" );

dofile( "functions.lua" );
dofile( "configuration.lua" );
dofile( "module.lua" );
dofile( "project.lua" );
dofile( "solution.lua" );
dofile( "targets.lua" );
