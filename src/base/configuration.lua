
ConfigurationRuntimeTypeInformation = {
	On			= "On",
	Off			= "Off"
}

ConfigurationExceptionHandling = {
	Default		= "Defult",
	On			= "On",
	Off			= "Off",
	SEH			= "SEH"
}

ConfigurationFloatingPoint = {
	Default		= "Default",
	Fast		= "Fast",
	Strict		= "Strict"
}

ConfigurationOptimization = {
	Off			= "Off",
	On			= "On",
	Debug		= "Debug",
	Size		= "Size",
	Speed		= "Speed",
	Full		= "Full"
}

ConfigurationCppDialect = {
	Default		= "Default",
	Cpp98		= "C++98",
	Cpp11		= "C++11",
	Cpp14		= "C++14",
	Cpp17		= "C++17"
}

ConfigurationSymbols = {
	Default		= "Default",
	Off			= "Off",
	On			= "On",
	FastLink	= "FastLink",
	Full		= "Full"
}

ConfigurationPrecompiledHeader = {
	Off			= "Off",
	On			= "On"
}

ConfigurationMultiProcessorCompile = {
	Off			= "Off",
	On			= "On"
}

ConfigurationSettings = {
	RuntimeTypeInformation	= 1,
	ExceptionHandling		= 2,
	FloatingPoint			= 3,
	Optimization			= 4,
	CppDialect				= 5,
	Symbols					= 6,
	PrecompiledHeader		= 7,
	MultiProcessorCompile	= 8
}

Configuration = class{
	defines = {},
	settings = {},
	flags = {},
	include_dirs = {},
	library_dirs = {},
	library_files = {},
	pre_build_steps = {},
	post_build_steps = {}
};

local global_configuration_setttings = {
	ConfigurationRuntimeTypeInformation,
	ConfigurationExceptionHandling,
	ConfigurationFloatingPoint,
	ConfigurationOptimization,
	ConfigurationCppDialect,
	ConfigurationSymbols,
	ConfigurationPrecompiledHeader,
	ConfigurationMultiProcessorCompile
}
assert( #global_configuration_setttings == table.length( ConfigurationSettings ) )

function Configuration:new()
	return class_instance( self );
end

function Configuration:check_base_path( base_path )
	if type( base_path ) ~= "string" then
		throw( "not base_path. too few arguments." )
	end
end

function Configuration:set_define( name, value )
	if type( name ) ~= "string" or (value ~= nil and type( value ) ~= "string") then
		throw("[set_define] Invalid args.")
	end

	if value == nil then
		table.insert( self.defines, name );
	else
		table.insert( self.defines, name .. "=" .. value );
	end
end

function Configuration:set_flag( name )
	if type( name ) ~= "string" then
		throw("[set_flag] Invalid args.")
	end

	table.insert( self.flags, name );
end

function Configuration:set_setting( setting, value )
	if type( setting ) ~= "number" or value == nil then
		throw("[set_setting] Invalid args.")
	end

	if not table.contains( ConfigurationSettings, setting ) then
		throw( "Invalid setting " .. setting )
	end
	
	local values = global_configuration_setttings[ setting ]
	if not table.contains( values, value ) then
		throw( "'" .. value .. "' is not a valid value for " .. table.keys( ConfigurationSettings )[ setting ] )
	end
	
	self.settings[ setting ] = value
end

function Configuration:add_include_dir( include_dir, base_path )
	if type( include_dir ) ~= "string" then
		throw "[add_include_dir] Invalid args.";
	end

	self:check_base_path( base_path );

	table.insert( self.include_dirs, path.join( base_path, include_dir ) );
end

function Configuration:add_library_dir( library_dir, base_path )
	if type( library_dir ) ~= "string" then
		throw "[add_library_dir] Invalid args.";
	end

	self:check_base_path( base_path );

	table.insert( self.library_dirs, path.join( base_path, library_dir ) );
end

function Configuration:add_library_file( library_filename )
	if type( library_filename ) ~= "string" then
		throw "[add_library_file] Invalid args.";
	end

	table.insert( self.library_files, library_filename );
end

function Configuration:add_pre_build_step( step_script, step_data, step_base_path )
	if type( step_script ) ~= "string" or type( step_data ) ~= "table" then
		throw "[add_pre_build_step] Invalid args.";
	end

	table.insert( self.pre_build_steps, { script = "actions/" .. step_script .. ".lua", base_path = step_base_path, data = step_data } );
end

function Configuration:add_post_build_step( step_script, step_data, step_base_path )
	if type( step_script ) ~= "string" or type( step_data ) ~= "table" then
		throw "[add_post_build_step] Invalid args.";
	end

	table.insert( self.post_build_steps, { script = "actions/" .. step_script .. ".lua", base_path = step_base_path, data = step_data } );
end

function Configuration:apply_configuration( target )
	if type( target ) ~= "table" then
		throw "[Configuration:apply_configuration] wrong target arguments.";
	end
	
	for setting, value in pairs( self.settings ) do
		if target.settings[ setting ] and target.settings[ setting ] ~= value then
			throw( "Settings conflict for '" .. table.keys( ConfigurationSettings )[ setting ] .. "' with value '" .. target.settings[ setting ] .. " ' and '" .. value .. "'." )
		end
		
		target.settings[ setting ] = value
	end
		
	target.defines = table.join( target.defines, self.defines );	
	target.flags = table.join( target.flags, self.flags );
	target.include_dirs = table.join( target.include_dirs, self.include_dirs );
	target.library_dirs = table.join( target.library_dirs, self.library_dirs );
	target.library_files = table.join( target.library_files, self.library_files );
	target.binary_dirs = table.join( target.binary_dirs, self.binary_dirs );
	target.binary_files = table.join( target.binary_files, self.binary_files );
	target.pre_build_steps = table.join( target.pre_build_steps, self.pre_build_steps );
	target.post_build_steps = table.join( target.post_build_steps, self.post_build_steps );
end
