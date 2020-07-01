
ProjectTypes = {
	ConsoleApplication	= "ConsoleApp",
	WindowApplication	= "WindowedApp",
	SharedLibrary		= "SharedLib",
	StaticLibrary		= "StaticLib"
}

ProjectLanguages = {
	Cpp		= "C++",
	Cs		= "C#"
}

Project = class{
	name = nil,
	type = nil,
	lang = ProjectLanguages.Cpp,
	module = nil,
	buildoptions = nil,
	platforms = {},
	configurations = {},
	generated_files_dir = ''
}

global_project_storage = {}

function find_project( project_name )
	for i,project in pairs( global_project_storage ) do
		if ( project.name == project_name ) then
			return project
		end
	end

	throw( "[find_project] Project with name '"..project_name.."' not found." )
	return nil
end

function Project:new( name, platforms, configurations, project_type )
	if not name then 
		throw( "No Project name given." )
	end

	if type( platforms ) ~= "table" or type( configurations ) ~= "table" then 
		throw( "Invalid Project platforms or configurations. Please provide an array." )
	end

	if not project_type then 
		throw( "Invalid Project type. Please use the ProjectTypes enum." )
	end

	local project_new = class_instance( self )
	project_new.name			= name
	project_new.type			= project_type
	project_new.module			= Module:new( name )
	project_new.configurations	= configurations
	project_new.platforms		= platforms

	table.insert( global_project_storage, project_new )
	
	return project_new
end

function Project:set_base_path( base_path )
	self.module:set_base_path( base_path )
end

function Project:add_files( file_name, flags )
	self.module:add_files( file_name, flags )
end

function Project:set_define( name, value, configuration, platform )
	self.module:set_define( name, value, configuration, platform )
end

function Project:set_flag( name, configuration, platform )
	self.module:set_flag( name, configuration, platform )
end

function Project:add_binary_dir( binary_dir, configuration, platform )
	self.module:add_binary_dir( binary_dir, configuration, platform )
end

function Project:add_include_dir( include_dir, configuration, platform )
	self.module:add_include_dir( include_dir, configuration, platform )
end

function Project:add_library_dir( library_dir, configuration, platform )
	self.module:add_library_dir( library_dir, configuration, platform )
end

function Project:add_binary_file( binary_filename, configuration, platform )
	self.module:add_binary_file( binary_filename, configuration, platform )
end

function Project:add_library_file( library_filename, configuration, platform )
	self.module:add_library_file( library_filename, configuration, platform )
end

function Project:add_pre_build_step( step_script, step_data, configuration, platform )
	self.module:add_pre_build_step( step_script, step_data, configuration, platform )
end

function Project:add_post_build_step( step_script, step_data, configuration, platform )
	self.module:add_post_build_step( step_script, step_data, configuration, platform )
end

function Project:add_dependency( module_name )
	self.module:add_dependency( module_name )
end

function Project:add_external( url )
	self.module:add_external( url )
end


function Project:add_install( pattern, target_path, configuration, platform )
	local config = self.module.config:get_config( configuration, platform )
	
	local step_script = path.join( global_configuration.scripts_path, "actions/install_binary.lua" )
	local step_data = {
		pattern = pattern,
		target = target_path
	}
	
	config:add_post_build_step( step_script, step_data )
end

function Project:finalize_create_directories()
	self.generated_files_dir = path.join( root_dir, tiki.generated_files_dir, self.name )
	if not os.isdir( self.generated_files_dir ) then
		print( "Create:" .. self.generated_files_dir )
		os.mkdir( self.generated_files_dir )
	end
end

function Project:finalize_create_configuration_directories( configuration, platform )
	local build_dir = get_config_dir( platform, configuration )
	
	if not os.isdir( build_dir ) then
		print( "Create:" .. build_dir )
		os.mkdir( build_dir )
	end
	
	return build_dir
end

function Project:finalize_binary( config )
	for i,file in pairs( config.binary_files ) do
		for j,dir in pairs( config.binary_dirs ) do
			local fullpath = path.join( dir, file )

			if os.isfile( fullpath ) then
				local step_script = path.join( global_configuration.scripts_path, "actions/copy_binary.lua" )
				local step_data = {
					source = fullpath,
					target = file
				}
				
				config:add_post_build_step( step_script, step_data )
				break
			end
		end
	end
end

function Project:finalize_config( config )
	local array_defines = table.uniq( config.defines )
	local array_flags = table.uniq( config.flags )
	local array_include_dirs = table.uniq( config.include_dirs )
	local array_library_dirs = table.uniq( config.library_dirs )
	local array_library_files = table.uniq( config.library_files )

	if array_defines then
		defines( array_defines )
	end
	
	if array_flags then
		flags( array_flags )
	end
	
	if array_include_dirs then
		includedirs( array_include_dirs )
	end
	
	if array_library_dirs then
		libdirs( array_library_dirs )
	end
	
	if array_library_files then
		links( array_library_files )
	end
end

function Project:finalize_build_steps( config, build_dir )
	if #config.pre_build_steps == 0 and #config.post_build_steps == 0 then
		-- no build actions
		return
	end
	
	local genie_exe = global_configuration.genie_path:gsub( "/", "\\" )
	local relative_build_dir = path.getrelative( _OPTIONS[ "to" ], build_dir )

	local global_filename = path.join( _OPTIONS[ "to" ], "genie.lua" )
	local global_file = io.open( global_filename, "w" )
	if global_file ~= nil then
		local script_path = path.getrelative( _OPTIONS[ "to" ], path.join( global_configuration.scripts_path, "buildsteps.lua" ) )
		global_file:write( "dofile( \"" .. script_path .. "\" )" )
		global_file:close()
	end
	
	if #config.pre_build_steps > 0 then
		local pre_build_steps_filename = "pre_build_steps_" .. self.name .. ".lua"
		local pre_build_steps_path = path.join( build_dir, pre_build_steps_filename )
		local pre_build_steps_file = io.open( pre_build_steps_path, "w" )
		if pre_build_steps_file ~= nil then
			pre_build_steps_file:write( DataDumper( config.pre_build_steps ) )
			pre_build_steps_file:close()
		end	
		
		local command_line = {
			genie_exe,
			"--quiet",
			"--project=" .. self.name,
			"--to=" .. relative_build_dir,
			"--script=" .. path.join( relative_build_dir, pre_build_steps_filename ),
			"buildsteps"
		}
		prebuildcommands{ table.concat( command_line, " " ) }
	end

	if #config.post_build_steps > 0 then
		local post_build_steps_filename = "post_build_steps_" .. self.name .. ".lua"
		local post_build_steps_path = path.join( build_dir, post_build_steps_filename )
		local post_build_steps_file = io.open( post_build_steps_path, "w" )
		if post_build_steps_file ~= nil then		
			post_build_steps_file:write( DataDumper( config.post_build_steps ) )
			post_build_steps_file:close()
		end
	
		command_line = {
			genie_exe,
			"--quiet",
			"--project=" .. self.name,
			"--to=" .. relative_build_dir,
			"--script=" .. path.join( relative_build_dir, post_build_steps_filename ),
			"buildsteps"
		}
		postbuildcommands{ table.concat( command_line, " " ) }
	end
end

function Project:finalize_project( solution )
	project( self.name )
	--uuid( self.uuid )
	kind( self.type )
	language( self.lang )
	
	if self.buildoptions then
		buildoptions( self.buildoptions )
	end
	
	self:finalize_create_directories()
	
	local config_project = Configuration:new()
	if self.lang == ProjectLanguages.cpp then
		config_project:set_define( "TIKI_PROJECT_NAME", self.name )

		if self.type == ProjectTypes.sharedLibrary or self.type == ProjectTypes.staticLibrary then
			config_project:set_define( "TIKI_BUILD_LIBRARY", "TIKI_ON" )
		else
			config_project:set_define( "TIKI_BUILD_LIBRARY", "TIKI_OFF" )
		end
	end

	local modules = {}
	self.module:resolve_dependency( modules )
	self.module:finalize( config_project, self, solution )
	
	for _,cur_module in pairs( modules ) do
		cur_module:finalize( config_project, self, solution )
	end

	local config_platform = {}
	for _,build_platform in pairs( self.platforms ) do
		--print( "Platform: " .. build_platform )
		configuration{ build_platform }

		config_platform[ build_platform ] = Configuration:new()

		self.module:finalize_configuration( config_platform[ build_platform ], nil, build_platform )
		for j,cur_module in pairs( modules ) do
			cur_module:finalize_configuration( config_platform[ build_platform ], nil, build_platform )
		end
	end

	local config_configuration = {}
	for _,build_config in pairs( self.configurations ) do
		--print( "Configuration: " .. build_config )
		configuration{ build_config }

		config_configuration[ build_config ] = Configuration:new()

		self.module:finalize_configuration( config_configuration[ build_config ], build_config, nil )
		for j,cur_module in pairs( modules ) do
			cur_module:finalize_configuration( config_configuration[ build_config ], build_config, nil )
		end
	end

	for _,build_platform in pairs( self.platforms ) do
		for j,build_config in pairs( self.configurations ) do
			if _ACTION ~= "targets" then
				print( "Configuration: " .. build_platform .. "/" .. build_config )
			end
			configuration{ build_platform, build_config }

			local build_dir = ''
			if _ACTION ~= "targets" then
				build_dir = self:finalize_create_configuration_directories( build_config, build_platform )

				targetdir( build_dir )
				debugdir( build_dir )
				objdir( path.join( build_dir, "obj" ) )
			end

			local config = Configuration:new()

			self.module:finalize_configuration( config, build_config, build_platform )
			for k,cur_module in pairs( modules ) do
				cur_module:finalize_configuration( config, build_config, build_platform )
			end	
			
			config_project:apply_configuration( config )
			config_platform[ build_platform ]:apply_configuration( config )
			config_configuration[ build_config ]:apply_configuration( config )
			
			self:finalize_binary( config, build_dir )
			self:finalize_config( config )
			
			if _ACTION ~= "targets" then
				self:finalize_build_steps( config, build_dir )
			end
		end
	end
end