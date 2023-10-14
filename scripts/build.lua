-- build premake with embedded tiki_build

if _ACTION == 'build' then
	newoption{ trigger = "spare", description = "Reuse the build directory" }
end

local script_path = path.getdirectory( _SCRIPT )
local root_path = path.getdirectory( script_path )

function force_delete( path )
	local files = os.matchfiles( path .. "/**" )
	for _, file in ipairs( files ) do
		local result, err = os.chmod( file, "777" )
		if not result then
			return nil, err
		end
		result, err = os.remove( file )
		if not result then
			return nil, err
		end
	end

	local result, err = os.rmdir( path )
	if not result then
		return nil, err
	end
	
	return true
end

function do_build()
	print( "Generate Script..." )
	local generate_command_line = _PREMAKE_COMMAND .. " generate"
	if not os.execute( generate_command_line ) then
		error( "Generate failed. Command line:" .. generate_command_line );
	end
	
	local build_path = path.join( root_path, "build" );
	local premake_path = path.join( build_path, "premake" )
	if not _OPTIONS.spare then
		print( "Recreate build directory..." )
		local result, err = force_delete( build_path );
		if not result then
			error( "Delete of build failed. Error: " .. err );
		end
		os.mkdir( build_path );
		
		print( "Clone Premake..." )
		local clone_command_line = "git clone https://github.com/premake/premake-core.git " .. premake_path
		if not os.execute( clone_command_line ) then
			error( "Clone failed. Command line: " .. clone_command_line );
		end

		print( "Patch Premake..." )
		os.chdir( premake_path )
		local patch_path = path.join( root_path, "premake5_tiki_build.patch" )
		local patch_command_line = "git apply " .. patch_path
		if not os.execute( patch_command_line ) then
			error( "Patch failed. Command line: " .. patch_command_line );
		end
	else
		os.chdir( premake_path )
	end
	
	print( "Copy Script..." )
	local source_script_path = path.join( root_path, "tiki_build.lua" );
	local target_script_path = path.join( premake_path, "tiki_build.lua" );
	os.copyfile( source_script_path, target_script_path )

	-- TODO: linux
	print( "Build Premake..." )
	local build_command_line = "Bootstrap.bat"
	if not os.execute( build_command_line ) then
		error( "Build failed. Command line: " .. build_command_line );
	end

	print( "Copy build result..." )
	local source_exe_path = path.join( premake_path, "bin/release/premake_tb.exe" )
	local target_exe_path = path.join( root_path, "premake_tb.exe" );
	result, err = os.copyfile( source_exe_path, target_exe_path )
	if not result then
		error( "Copy failed. Error: " .. err );
	end
end

newaction {
	trigger     = "build",
	description = "Build premake5 with tiki_build",
	execute     = do_build
}