
Module = class{
	name = nil,
	module_type = 0,
	import_func = nil,
	config = nil,
	module_dependencies = {},
	external_dependencies = {},
	source_files = {},
	exclude_files = {},
	optional_files = {},
	stack_trace = ""
}

global_module_include_pathes = {}
global_module_storage = {}

ModuleTypes = {
	UnityCppModule	= 0,
	UnityCModule	= 1,
	FilesModule		= 2
}

if not tiki.default_module_type then
	tiki.default_module_type = ModuleTypes.UnityCppModule
end

function add_module_include_path( include_path )
	if path.isabsolute( include_path ) then
		throw( "Please use relative pathes for module include pathes."  )
	end
	
	local module_include_path = path.getabsolute( path.join( path.getdirectory( _SCRIPT ), include_path ) )
	for _, include_path in pairs( global_module_include_pathes ) do
		if include_path == module_include_path then
			return
		end
	end

	table.insert( global_module_include_pathes, module_include_path )
end

function find_module( module_name, importer_name )
	local import_name = module_name
	local import_base = "."
	local import_name_slash = module_name:find( "/" )
	if import_name_slash ~= nil then
		import_name = module_name:sub( import_name_slash + 1 )
		import_base = module_name:sub( 0, import_name_slash - 1 )
	end

	for _, module in pairs( global_module_storage ) do
		if module.name == import_name then
			return module
		end
	end
	
	--print( "Search for: " .. import_base .. "/" .. import_name )
	local module_found = false
	local module_filename = ""
	for i, include_path in pairs( global_module_include_pathes ) do
		local import_path = path.join( include_path, import_base )
		local module_path = path.join( import_path, import_name )
	
		local filename = path.join( module_path, import_name .. ".lua" )
		--print( "Try: " .. filename )
		if os.isfile( filename ) then
			if module_found then
				throw( "Module " .. import_name .. " has multiple file locations:\n" .. module_filename .. "\nand:\n" .. filename )
			end
		
			dofile( filename )
			module_found = true
			module_filename = filename
		end
	end
	
	if not module_found then
		print( "Module " .. module_name .. " not found. Search pathes:" )
		for i,include_path in pairs( global_module_include_pathes ) do
			print( "Path: " .. include_path )
		end
		throw( "Can not import " .. module_name )
	end
	
	if #global_module_storage > 0 then
		local last_module = global_module_storage[ #global_module_storage ]
		if last_module.name == import_name then
			return last_module
		end
	end
	
	print( "Model include directories:" )
	for _, include_path in pairs( global_module_include_pathes ) do
		print( include_path )
	end
	
	local error_text = "Module with name '" .. module_name .. "' not found."
	if ( importer_name ) then
		error_text = error_text .. " Imported by " .. importer_name .. "!"
	end
	throw( error_text )
	return nil
end

function Module:new( name, initFunc )
	if name == nil then
		local source = debug.getinfo( 2 ).source
		name = source:match( "([^/]+).lua$" )
	end

	for _,module in pairs( global_module_storage ) do
		if ( module.name == name ) then
			throw( "Module name already used: " .. name .. "\nmodule " .. module.stack_trace )
		end
	end

	local module_new = class_instance( self )
	module_new.name			= name
	module_new.config		= PlatformConfiguration:new()
	module_new.module_type	= tiki.default_module_type
	module_new.stack_trace	= debug.traceback()
		
	table.insert( global_module_storage, module_new )

	if ( initFunc ~= nil and type( initFunc ) == "function" ) then
		initFunc( module_new )
	end

	return module_new
end

function Module:set_base_path( base_path )
	self.config:set_base_path( base_path )
end

function Module:add_files( file_name, flags )
	if type( file_name ) ~= 'string' then
		throw( "invalid argument in add_files: file_name must be a string" )
	end

	local target_list = self.source_files
	if type( flags ) == "table" then
		if flags.exclude then
			target_list = self.exclude_files
		elseif flags.optional then
			target_list = self.optional_files
		end
	end

	table.insert( target_list, path.join( self.config.base_path, file_name ) )
end

function Module:set_define( name, value, configuration, platform )
	self.config:set_define( name, value, configuration, platform )
end

function Module:set_flag( name, configuration, platform )
	self.config:set_flag( name, configuration, platform )
end

function Module:add_binary_dir( binary_dir, configuration, platform )
	self.config:add_binary_dir( binary_dir, configuration, platform )
end

function Module:add_include_dir( include_dir, configuration, platform )
	self.config:add_include_dir( include_dir, configuration, platform )
end

function Module:add_library_dir( library_dir, configuration, platform )
	self.config:add_library_dir( library_dir, configuration, platform )
end

function Module:add_binary_file( binary_filename, configuration, platform )
	self.config:add_binary_file( binary_filename, configuration, platform )
end

function Module:add_library_file( library_filename, configuration, platform )
	self.config:add_library_file( library_filename, configuration, platform )
end

function Module:add_pre_build_step( step_script, step_data, configuration, platform )
	self.config:add_pre_build_step( step_script, step_data, configuration, platform )
end

function Module:add_post_build_step( step_script, step_data, configuration, platform )
	self.config:add_post_build_step( step_script, step_data, configuration, platform )
end

function Module:add_dependency( module_name )
	if not type( module_name ) == "string" then
		throw( "module_name of a dependency must be a valid string." )		
	end

	table.insert( self.module_dependencies, module_name )
end

function Module:add_external( url )
	if not type( url ) == "string" then
		throw( "url of a external dependency must be a valid string." )		
	end

	table.insert( self.external_dependencies, url )
end

function Module:resolve_dependency( target_list )
	for _, module_name in ipairs( self.module_dependencies ) do
		local module = find_module( module_name, self.name )

		if not table.contains( target_list, module ) then
			table.insert( target_list, module )
			module:resolve_dependency( target_list )
		end		
	end
	
	for _, url in ipairs( self.external_dependencies ) do
		local module = find_external_module( url )
		
		if not table.contains( target_list, module ) then
			table.insert( target_list, module )
			module:resolve_dependency( target_list )
		end	
	end
end

function Module:finalize_files( project )
	local is_unity_module = tiki.enable_unity_builds and (self.module_type == ModuleTypes.UnityCppModule or self.module_type == ModuleTypes.UnityCModule)

	local all_files = {}
	for _,pattern in pairs( self.source_files ) do
		local matches = os.matchfiles( pattern )
		
		if #matches == 0 then
			throw( pattern .. "' pattern in '" .. self.name .. "' matches no files." )
		end
		
		for j, file_name in pairs( matches ) do
			if not io.exists( file_name ) then
				throw("[finalize] '" .. file_name .. "'  in '" .. self.name .. "' don't exists.")
			end
			
			if not table.contains( all_files, file_name ) then
				all_files[#all_files+1] = file_name
			end					
		end
	end
	
	for _,pattern in pairs( self.optional_files ) do
		local matches = ""
		if path.isabsolute( pattern ) then
			matches = { pattern }
		else
			matches = os.matchfiles( pattern )
		end
	
		for _,file_name in pairs( matches ) do
			if not table.contains( all_files, file_name ) then
				all_files[#all_files+1] = file_name
			end					
		end
	end
	
	for _,pattern in pairs( self.exclude_files ) do
		local matches = os.matchfiles( pattern )
		
		for j,file_name in pairs( matches ) do
			local index = table.index_of( all_files, file_name )
			
			while index >= 0 do
				table.remove( all_files, index )
			
				index = table.index_of( all_files, file_name )
			end
		end
	end

	if is_unity_module then
		configuration( "Project" )
	end
	files( all_files )
	configuration{}

	if is_unity_module then
		local ext = iff( self.module_type == ModuleTypes.UnityCModule, "c", "cpp" )		
		local unity_file_name = path.join( project.generated_files_dir, self.name .. "_unity." .. ext )			
		local c = {}
		c[#c+1] = "// Unity file created by GENie"
		c[#c+1] = ""
		c[#c+1] = "#define TIKI_CURRENT_MODULE \"" .. self.name .. "\""
		c[#c+1] = ""
		for i,file_name in pairs( all_files ) do
			if path.iscppfile( file_name ) then
				local relative_file_name = path.getrelative( project.generated_files_dir, file_name )
				c[#c+1] = string.format( "#include \"%s\"", relative_file_name )
			end
		end
		local unity_content = table.concat( c, "\n" )

		--excludes( all_files )
		
		if _ACTION ~= "targets" then
			local create_unity = true
			if os.isfile( unity_file_name ) then
				local unity_file = io.open( unity_file_name, "r" )
				if unity_file ~= nil then
					local unity_current_content = unity_file:read("*all")
					if unity_current_content == unity_content then
						create_unity = false
					end					
					unity_file:close()
				end
			end
			
			if create_unity then
				print( "Create Unity file: " .. path.getname( unity_file_name ) )
				local unity_file = io.open( unity_file_name, "w" )
				if unity_file ~= nil then
					unity_file:write( unity_content )
					unity_file:close()
				end
			end
		end
		
		files( { unity_file_name } )
	end
end

function Module:finalize(  config, project, solution )
	if self.import_func ~= nil and type( self.import_func ) == "function" then
		self.import_func( project, solution )
	end
	
	self:finalize_files( project )
	
	self.config:get_config( nil, nil ):apply_configuration( config )
end

function Module:finalize_configuration( config, configuration, platform )
	self.config:get_config( configuration, platform ):apply_configuration( config )
end
