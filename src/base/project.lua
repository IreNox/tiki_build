
ProjectTypes = {
	ConsoleApplication	= "ConsoleApp",
	WindowApplication	= "WindowedApp",
	SharedLibrary		= "SharedLib",
	StaticLibrary		= "StaticLib",
	Package				= "Packaging"
}

Project = class{
	name = nil,
	type = nil,
	module = nil,
	buildoptions = {},
	linkoptions = {},
	dependencies = {},
	generated_files_dir = ''
}

ProjectExtensions = Extendable:new()

local global_project_storage = {}

function find_project( project_name )
	for i,project in pairs( global_project_storage ) do
		if ( project.name == project_name ) then
			return project
		end
	end

	throw( "[find_project] Project with name '"..project_name.."' not found." )
	return nil
end

function Project:new( name, project_type )
	if project_type == nil then
		project_type = name;

		local source = debug.getinfo( 2 ).source
		name = path.getname( path.getdirectory( source ) )
	end

	if type( name ) ~= "string" then 
		throw( "No Project name given." )
	end

	if type( project_type ) ~= "string" or not table.contains( ProjectTypes, project_type ) then 
		throw( "Invalid Project type. Please use the ProjectTypes enum." )
	end

	local project_new = class_instance( self )
	project_new.name	= name
	project_new.type	= project_type
	project_new.module	= Module:new( name .. "_project" )

	table.insert( global_project_storage, project_new )
	
	ProjectExtensions:execute_new_hook( project_new )

	return project_new
end

function Project:set_base_path( base_path )
	self.module:set_base_path( base_path )
end

function Project:add_files( file_name, flags )
	self.module:add_files( file_name, flags )
end

function Project:add_define( name, configuration, platform )
	self.module:add_define( name, configuration, platform )
end

function Project:set_define( name, value, configuration, platform )
	self.module:set_define( name, value, configuration, platform )
end

function Project:set_flag( name, configuration, platform )
	self.module:set_flag( name, configuration, platform )
end

function Project:set_setting( setting, value, configuration, platform )
	self.module:set_setting( setting, value, configuration, platform )
end

function Project:add_include_dir( include_dir, configuration, platform )
	self.module:add_include_dir( include_dir, configuration, platform )
end

function Project:add_library_dir( library_dir, configuration, platform )
	self.module:add_library_dir( library_dir, configuration, platform )
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

function Project:add_project_dependency( project )
	if table.contains( self.dependencies, project ) then
		return
	end

	table.insert( self.dependencies, project )
end

function Project:add_install( pattern, target_path, configuration, platform )
	local config = self.module.config:get_config( configuration, platform )
	
	local step_data = {
		pattern = pattern,
		target = target_path
	}
	
	config:add_post_build_step( "install_files", step_data, self.module.config.base_path )
end

function Project:execute_build_step( script, data )
	local config = {
		project_name = self.name,
		build_path = path.getabsolute( _OPTIONS[ "to" ] ),
		base_path = self.module.config.base_path,
		output_path = path.getabsolute( _OPTIONS[ "to" ] )
	}
	
	tiki.execute_build_step( script, data, config )
end

function Project:finalize_create_directories()
	self.generated_files_dir = path.getabsolute( path.join( _OPTIONS[ "to" ], tiki.generated_files_dir, self.name ) )
	if not os.isdir( self.generated_files_dir ) then
		print( "Create:" .. self.generated_files_dir )
		os.mkdir( self.generated_files_dir )
	end
end

function Project:finalize_create_configuration_directories( configuration, platform )
	local build_dir = tiki.get_config_dir( platform, configuration )
	
	if not os.isdir( build_dir ) then
		print( "Create:" .. build_dir )
		os.mkdir( build_dir )
	end
	
	return build_dir
end

function Project:finalize_config( config )
	local final_defines = table.uniq( config.defines )
	local final_flags = table.uniq( config.flags )
	local final_include_dirs = table.uniq( config.include_dirs )
	local final_library_dirs = table.uniq( config.library_dirs )
	local final_library_files = table.uniq( config.library_files )
	
	if final_defines then
		defines( final_defines )
	end
	
	if final_flags then
		flags( final_flags )
	end
	
	if final_include_dirs then
		includedirs( final_include_dirs )
	end
	
	if final_library_dirs then
		libdirs( final_library_dirs )
	end
	
	if final_library_files then
		links( final_library_files )
	end
	
	for setting, value in pairs( config.settings ) do
		if setting == ConfigurationSettings.RuntimeTypeInformation then
			rtti( value )
		elseif setting == ConfigurationSettings.ExceptionHandling then
			exceptionhandling( value )
		elseif setting == ConfigurationSettings.FloatingPoint then
			floatingpoint( value )
		elseif setting == ConfigurationSettings.Optimization then
			optimize( value )
		elseif setting == ConfigurationSettings.CppDialect then
			cppdialect( value )
		elseif setting == ConfigurationSettings.Symbols then
			symbols( value )
		elseif setting == ConfigurationSettings.PrecompiledHeader then
			if value == ConfigurationPrecompiledHeader.Off then
				flags{ "NoPCH" }
			end
		elseif setting == ConfigurationSettings.MultiProcessorCompile then
			if value == ConfigurationMultiProcessorCompile.On then
				flags{ "MultiProcessorCompile" }
			end
		else
			throw( "Invalid setting " .. setting )
		end
	end
end

function Project:finalize_build_steps_command_line( steps_name, steps, build_dir )
	if #steps == 0 then
		return {}
	end
	
	local relative_build_dir = path.getrelative( _OPTIONS[ "to" ], build_dir )

	local build_steps_filename = steps_name .. "_" .. self.name .. ".lua"
	local build_steps_path = path.join( build_dir, build_steps_filename )
	local build_steps_file = io.open( build_steps_path, "w" )
	if build_steps_file ~= nil then
		build_steps_file:write( DataDumper( steps ) )
		build_steps_file:close()
	end	
	
	local command_line = {
		_PREMAKE_COMMAND,
		"--quiet",
		"--script=" .. path.join( relative_build_dir, build_steps_filename ),
		"--project=" .. self.name,
		"--to=" .. relative_build_dir,
	}
	
	if not tiki.executable_included then
		local system_script = path.getrelative( _OPTIONS[ "to" ], path.join( tiki.root_path, "tiki_build.lua" ) )
		table.insert( command_line, "--systemscript=" .. system_script )
	end
	
	table.insert( command_line, "buildsteps" )
	
	return { table.concat( command_line, " " ) }
end

function Project:finalize_build_steps( config, build_dir )
	local pre_build_steps = self:finalize_build_steps_command_line( "pre_build_steps", config.pre_build_steps, build_dir )
	prebuildcommands( pre_build_steps )

	local post_build_steps = self:finalize_build_steps_command_line( "post_build_steps", config.post_build_steps, build_dir )
	postbuildcommands( post_build_steps )
end

function Project:finalize( solution )
	ProjectExtensions:execute_pre_finalize_hook( solution, self )

	project( self.name )
	kind( self.type )
	language( "C++" )
	
	if tiki.host_platform == Platforms.Windows and tiki.target_platform == Platforms.Linux then
		-- TODO: wait for PR: debugger( "LinuxWSLDebugger" )
		toolchainversion( "wsl2" )
	end
	
	self:finalize_create_directories()
	
	local config_project = Configuration:new()
	
	solution:finalize_configuration( config_project, nil, nil )
	self.module:finalize_configuration( config_project, nil, nil )
	
	config_project:set_define( "TIKI_PROJECT_NAME", self.name )

	local is_library = self.type == ProjectTypes.SharedLibrary or self.type == ProjectTypes.StaticLibrary
	config_project:set_define( "TIKI_BUILD_LIBRARY", iff( is_library, "TIKI_ON", "TIKI_OFF" ) )

	local is_window_app = self.type == ProjectTypes.WindowApplication
	config_project:set_define( "TIKI_BUILD_WINDOW_APP", iff( is_window_app, "TIKI_ON", "TIKI_OFF" ) )
	
	local modules = {}
	self.module:resolve_dependency( modules )
	
	for _,cur_module in pairs( modules ) do
		cur_module:finalize( solution, self, config_project )
	end
	
	for _, project in ipairs( self.dependencies ) do
		if project.type == ProjectTypes.SharedLibrary or project.type == ProjectTypes.StaticLibrary then
			print( "Add Lib: " .. project.name )
			config_project:add_library_file( project.name )
		end

		dependson{ project.name }
	end

	self.module:finalize( solution, self, config_project )

	local config_platform = {}
	for _,build_platform in pairs( solution.platforms ) do
		--print( "Platform: " .. build_platform )
		filter( "platforms:" .. build_platform )

		config_platform[ build_platform ] = Configuration:new()

		solution:finalize_configuration( config_platform[ build_platform ], nil, build_platform )
		self.module:finalize_configuration( config_platform[ build_platform ], nil, build_platform )
		for j,cur_module in pairs( modules ) do
			cur_module:finalize_configuration( config_platform[ build_platform ], nil, build_platform )
		end
	end

	local config_configuration = {}
	for _,build_config in pairs( solution.configurations ) do
		--print( "Configuration: " .. build_config )
		filter( "configurations:" .. build_config )

		config_configuration[ build_config ] = Configuration:new()

		solution:finalize_configuration( config_configuration[ build_config ], build_config, nil )
		self.module:finalize_configuration( config_configuration[ build_config ], build_config, nil )
		for j,cur_module in pairs( modules ) do
			cur_module:finalize_configuration( config_configuration[ build_config ], build_config, nil )
		end
	end

	for _,build_platform in pairs( solution.platforms ) do
		for j,build_config in pairs( solution.configurations ) do
			if _ACTION ~= "targets" then
				print( "Configuration: " .. build_platform .. "/" .. build_config )
			end
			filter{ "platforms:" .. build_platform, "configurations:" .. build_config }

			local build_dir = ''
			if _ACTION ~= "targets" then
				build_dir = self:finalize_create_configuration_directories( build_config, build_platform )

				targetdir( build_dir )
				debugdir( build_dir )
				objdir( path.join( build_dir, "obj" ) )
			end

			local config = Configuration:new()

			solution:finalize_configuration( config, build_config, build_platform )
			self.module:finalize_configuration( config, build_config, build_platform )
			for k,cur_module in pairs( modules ) do
				cur_module:finalize_configuration( config, build_config, build_platform )
			end	
			
			config_project:apply_configuration( config )
			config_platform[ build_platform ]:apply_configuration( config )
			config_configuration[ build_config ]:apply_configuration( config )
			
			self:finalize_config( config )
			
			if _ACTION ~= "targets" then
				self:finalize_build_steps( config, build_dir )
			end
		end
	end
	
	filter{}

	if #self.buildoptions > 0 then
		buildoptions( self.buildoptions )
	end

	if #self.linkoptions > 0 then
		linkoptions( self.linkoptions )
	end
	
	ProjectExtensions:execute_post_finalize_hook( solution, self )
end