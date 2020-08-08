
-- TODO:
--SolutionConfigurations = {
--	Debug		= 0,
--	Profile		= 1,
--	Release		= 2,
--	Master		= 3
--}
--
--SolutionPlatforms = {
--	x86,
--	x64,
--	ARM,
--	ARM64
--}

Solution = class{
	name = nil,
	config = nil,
	projects = {}
}

function add_extension( name )
	local script_path = "extensions/extension." .. name .. ".lua"
	tiki.dofile( script_path )
end

function Solution:new( name )
	if not name then
		local source = debug.getinfo( 2 ).source
		name = source:match( "([^/]+)/genie.lua$" )
	end

	local solution_new = class_instance( self )
	solution_new.name	= name
	solution_new.config	= ConfigurationSet:new()
	
	return solution_new
end

function Solution:add_project( project )
	if type( project ) ~= "table" then
		throw "[Solution:add_project] project argument is invalid."
	end

	if table.contains( self.projects, project ) then 
		return
	end
	
	table.insert( self.projects, project )
end

function Solution:finalize()
	local var_platforms = {}
	local var_configurations = {}

	for i,project in pairs( self.projects ) do
		for i,platform in pairs( project.platforms ) do
			if not table.contains( var_platforms, platform ) then 
				table.insert( var_platforms, platform )
			end
		end
		for j,configuration in pairs( project.configurations ) do
			if not table.contains( var_configurations, configuration ) then 
				table.insert( var_configurations, configuration )
			end
		end
	end
	table.insert( var_configurations, 'Project' )
	
	workspace( self.name )
	configurations( var_configurations )
	platforms( var_platforms )
	systemversion( "latest" )
	location( _OPTIONS[ "to" ] )
	
	if not os.isdir( _OPTIONS[ "to" ] ) then
		print( "Create:" .. _OPTIONS[ "to" ] )
		os.mkdir( _OPTIONS[ "to" ] )
	end

	while #self.projects > 0 do
		local project = self.projects[ next( self.projects ) ]
		if _ACTION ~= "targets" then
			print( "Project: " .. project.name )
		end

		project:finalize_project( self )
		table.remove_value( self.projects, project )
	end
	
	configuration{ "Project" }
	kind( "Makefile" )
	buildcommands{ _PREMAKE_COMMAND .. " /scripts=.. /to=" .. _OPTIONS[ "to" ] .. " " .. _ACTION }
end

function Solution:finalize_configuration( config, configuration, platform )
	self.config:get_config( configuration, platform ):apply_configuration( config )
end

function finalize_default_solution( ... )
	local projects = {...}

	local source = debug.getinfo( 2 ).source
	local name = source:match( "([^/]+)/premake5.lua$" )
	
	local solution = Solution:new( name )
	
	solution.config:set_define( "DEBUG", nil, "Debug" );
	solution.config:set_define( "_DEBUG", nil, "Debug" );
	solution.config:set_setting( ConfigurationSettings.Optimization, ConfigurationOptimization.Debug, "Debug" );
	solution.config:set_setting( ConfigurationSettings.Symbols, ConfigurationSymbols.Full, "Debug" );
	solution.config:set_setting( ConfigurationSettings.FloatingPoint, ConfigurationFloatingPoint.Fast, "Debug" );
	
	solution.config:set_define( "NDEBUG", nil, "Release" );
	solution.config:set_setting( ConfigurationSettings.Optimization, ConfigurationOptimization.Speed, "Release" );
	solution.config:set_setting( ConfigurationSettings.Symbols, ConfigurationSymbols.Default, "Release" );
	solution.config:set_setting( ConfigurationSettings.FloatingPoint, ConfigurationFloatingPoint.Fast, "Release" );
	
	solution.config:set_define( "NDEBUG", nil, "Master" );
	solution.config:set_setting( ConfigurationSettings.Optimization, ConfigurationOptimization.Speed, "Master" );
	solution.config:set_setting( ConfigurationSettings.Symbols, ConfigurationSymbols.Default, "Master" );
	solution.config:set_setting( ConfigurationSettings.FloatingPoint, ConfigurationFloatingPoint.Fast, "Master" );
	
	solution.config:set_setting( ConfigurationSettings.CppDialect, ConfigurationCppDialect.Cpp11 );
	solution.config:set_setting( ConfigurationSettings.RuntimeTypeInformation, ConfigurationRuntimeTypeInformation.Off );
	solution.config:set_setting( ConfigurationSettings.ExceptionHandling, ConfigurationExceptionHandling.Off );
	solution.config:set_setting( ConfigurationSettings.PrecompiledHeader, ConfigurationPrecompiledHeader.Off );
	solution.config:set_setting( ConfigurationSettings.MultiProcessorCompile, ConfigurationMultiProcessorCompile.On );

	for _, project in ipairs( projects ) do
		solution:add_project( project )
	end
	
	solution:finalize()
end
