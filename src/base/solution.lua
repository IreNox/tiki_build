
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
	configurations = nil,
	platforms = nil,
	projects = {}
}

SolutionExtensions = Extendable:new()

function Solution:new( name, configurations, platforms )
	if type( name ) ~= "string" then
		throw( "No Solutuion name specified." )
	end
	
	if type( configurations ) ~= "table" or type( platforms ) ~= "table" then 
		throw( "Invalid Solutuion platforms or configurations. Please provide an array." )
	end

	local solution_new = class_instance( self )
	solution_new.name			= name
	solution_new.config			= ConfigurationSet:new()
	solution_new.configurations	= configurations
	solution_new.platforms		= platforms

	SolutionExtensions:execute_new_hook( project_new )
	
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
	SolutionExtensions:execute_pre_finalize_hook( self )

	table.insert( self.configurations, 'Project' )
	
	workspace( self.name )
	configurations( self.configurations )
	platforms( self.platforms )
	systemversion( "latest" )
	location( _OPTIONS[ "to" ] )
	
	if not os.isdir( _OPTIONS[ "to" ] ) then
		print( "Create:" .. _OPTIONS[ "to" ] )
		os.mkdir( _OPTIONS[ "to" ] )
	end

	if #self.projects > 0 then
		local _, project = next( self.projects )
		print( "Start Project: " .. project.name )
		startproject( project.name )
	end

	while #self.projects > 0 do
		local _, project = next( self.projects )
		if _ACTION ~= "targets" then
			print( "Project: " .. project.name )
		end
		
		project:finalize( self )
		table.remove_value( self.projects, project )
	end
	
	configuration{ "Project" }
	kind( "Makefile" )
	buildcommands{ _PREMAKE_COMMAND .. " /scripts=.. /to=" .. _OPTIONS[ "to" ] .. " " .. _ACTION }
	
	SolutionExtensions:execute_post_finalize_hook( self )
end

function Solution:finalize_configuration( config, configuration, platform )
	self.config:get_config( configuration, platform ):apply_configuration( config )
end

function finalize_default_solution( ... )
	local projects = {...}

	local source = debug.getinfo( 2 ).source
	local name = source:match( "([^/]+)/premake5.lua$" )
	
	local configurations = { "Debug", "Release" }
	local platforms = { "x86", "x64" }
	if tiki.target_platform == Platforms.Android then
		table.insert( platforms, "arm" )
		table.insert( platforms, "arm64" )
	end
	
	local solution = Solution:new( name, configurations, platforms )
	
	solution.config:set_define( "DEBUG", nil, "Debug" )
	solution.config:set_define( "_DEBUG", nil, "Debug" )
	solution.config:set_setting( ConfigurationSettings.Optimization, ConfigurationOptimization.Debug, "Debug" )
	solution.config:set_setting( ConfigurationSettings.Symbols, ConfigurationSymbols.Full, "Debug" )
	solution.config:set_setting( ConfigurationSettings.FloatingPoint, ConfigurationFloatingPoint.Fast, "Debug" )
	
	solution.config:set_define( "NDEBUG", nil, "Release" )
	solution.config:set_setting( ConfigurationSettings.Optimization, ConfigurationOptimization.Speed, "Release" )
	solution.config:set_setting( ConfigurationSettings.Symbols, ConfigurationSymbols.Default, "Release" )
	solution.config:set_setting( ConfigurationSettings.FloatingPoint, ConfigurationFloatingPoint.Fast, "Release" )
	
	solution.config:set_setting( ConfigurationSettings.CppDialect, ConfigurationCppDialect.Cpp11 )
	solution.config:set_setting( ConfigurationSettings.RuntimeTypeInformation, ConfigurationRuntimeTypeInformation.Off )
	solution.config:set_setting( ConfigurationSettings.ExceptionHandling, ConfigurationExceptionHandling.Off )
	solution.config:set_setting( ConfigurationSettings.PrecompiledHeader, ConfigurationPrecompiledHeader.Off )
	solution.config:set_setting( ConfigurationSettings.MultiProcessorCompile, ConfigurationMultiProcessorCompile.On )

	for _, project in ipairs( projects ) do
		solution:add_project( project )
	end
	
	solution:finalize()
end
