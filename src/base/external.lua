
ExternalTypes = {
	SVN		= 'svn',
	Git		= 'git',
	Vcpkg	= 'vcpkg',
	Local	= 'local',
	Custom	= 'custom'
}

External = class{
	url = nil,
	type = nil,
	version = nil,
	file_path = nil,
	export_path = nil,
	import_file = nil,
	import_func = nil,
	module = nil
}

local global_external_storage = {}

function External:new( url )
	local external_new = class_instance( self )
	external_new.url		= url:match( '(.*)@' ) or url:match( '(.*)$' )
	external_new.version	= url:match( '@(.*)$' )
	
	local file_path = external_new.url
	file_path = file_path:gsub( ":", "" )
	file_path = file_path:gsub( "//", "/" )
	external_new.file_path = file_path

	local url_protocol = url:match( '^(.*):' )
	if url_protocol == "svn" then
		external_new.type = ExternalTypes.SVN
	elseif url_protocol == "git" then
		external_new.type = ExternalTypes.Git
	elseif url_protocol == "https" and external_new.url:endswith( ".git" ) then
		external_new.type = ExternalTypes.Git
	elseif url_protocol == "vcpkg" then
		external_new.type = ExternalTypes.Vcpkg
	elseif url_protocol == "local" then
		external_new.type = ExternalTypes.Local
	elseif url_protocol == "https" then
		external_new.type = ExternalTypes.Custom
	else
	   throw( "External type '" .. url_protocol .. "' used by '" .. url .. "' is not supported." )
	end
	
	if external_new.version == nil then
		if external_new.type == ExternalTypes.SVN then
			external_new.version = 'HEAD'
		elseif external_new.type == ExternalTypes.Git then
			external_new.version = 'master'
		elseif external_new.type == ExternalTypes.Vcpkg then
			external_new.version = 'latest'
		elseif external_new.type == ExternalTypes.Local then
			external_new.version = 'latest'
		elseif external_new.type == ExternalTypes.Custom then
			external_new.version = 'latest'
		end
	end
	
	table.insert( global_external_storage, external_new )
	
	return external_new
end

function External:check_svn()
	local command_line = tiki.svn_path .. " --version > nul"
	local exit_code = os.execute( command_line )
	if not exit_code then
		throw( 'svn could not be executed.' )
	end
end

function External:check_git()
	local command_line = tiki.git_path .. " --version > nul"
	local exit_code = os.execute( command_line )
	if not exit_code then
		throw( 'git could not be executed.' )
	end
end

function External:check_vcpkg()
	self:check_git()
	
	local vcpkg_path = path.getdirectory( self.export_path )
	if not os.isdir( vcpkg_path ) then
		local command_line = tiki.git_path .. " clone --depth 1 https://github.com/microsoft/vcpkg.git " .. vcpkg_path
	
		local exit_code = os.execute( command_line )
		if not exit_code then
			throw( 'git could not clone vcpkg.' )
		end
		
		local bootstrap_ext = iff( tiki.host_platform == Platforms.Windows, ".bat", ".sh" )
		command_line = path.join( vcpkg_path, "bootstrap-vcpkg" .. bootstrap_ext )
		print( command_line )
		
		exit_code = os.execute( command_line )
		if not exit_code then
			throw( 'vcpkg bootstrap failed.' )
		end
	end
	
	local vcpkg_ext = iff( tiki.host_platform == Platforms.Windows, ".exe", "" )
	local command_line = path.join( vcpkg_path, "vcpkg" .. vcpkg_ext ) .. " --vcpkg-root \"" .. vcpkg_path .. "\" --version > nul"
	local exit_code = os.execute( command_line )
	if not exit_code then
		throw( 'vcpkg could not be executed.' )
	end
end

function External:export( additional_import_path )
	if self.type == ExternalTypes.Local then
		local url_path = string.sub( self.url, 9, -1 )
		self.export_path = path.join( additional_import_path, url_path )
		return
	end

	local externals_dir = path.getabsolute( path.join( _OPTIONS[ "to" ], tiki.externals_dir ) )
	self.export_path = path.join( externals_dir, self.file_path )
	
	if self.type == ExternalTypes.SVN then
		self:export_svn()
	elseif self.type == ExternalTypes.Git then
		self:export_git()
	elseif self.type == ExternalTypes.Vcpkg then
		self.export_path = path.join( externals_dir, "vcpkg/installed" )
	
		self:check_vcpkg()
	else
		os.mkdir( self.export_path )
	end
end

function External:export_svn()
	self:check_svn()
	
	local exists = os.isdir( self.export_path )
	if exists then
		local command_line = tiki.svn_path .. " info " .. self.export_path
		local info_result = os.execute( command_line )
		if not info_result then
			exists = false
			print( "External " .. self.url .. " has a broken export at '" .. self.export_path .. "', so it will be reexported." )
			os.rmdir( self.export_path )
		end
	end
	
	if not exists then
		local command_line = tiki.svn_path .. " checkout " .. self.url .. "@" .. self.version .. " " .. self.export_path
		local checkout_result = os.execute( command_line )
		if checkout_result ~= 0 then
			throw( "Failed to checkout '" .. self.url .. "' to '" .. self.export_path .. "' with exit code " .. checkout_result .. "." )
		end			
	end
end

function External:export_git()
	local base_command_line = tiki.git_path .. " -C " .. self.export_path .. " "

	self:check_git()
	
	local exists = os.isdir( self.export_path )
	if exists then
		print( "Check existants " .. self.url .."..." )
		local info_result = os.outputof( base_command_line .. "status -s" )
		if not info_result then
			exists = false
			print( "External " .. self.url .. " has a broken export at '" .. self.export_path .. "', so it will be reexported." )
			os.rmdir( self.export_path )
		end
	end
	
	if not exists then
		print( "Clone " .. self.url .."..." )
		local command_line = tiki.git_path .. " clone --depth 1 --recurse-submodules " .. self.url .. " " .. self.export_path
		local clone_result = os.execute( command_line )
		if not clone_result then
			throw( "Failed to clone '" .. self.url .. "' to '" .. self.export_path .. "'." )
		end
	end
	
	-- check status
	print( "Get version of " .. self.url .."..." )
	local head = os.outputof( base_command_line .. "rev-parse --abbrev-ref HEAD" )
	if head == "HEAD" then
		head = os.outputof( base_command_line .. "rev-parse HEAD" )
	end
	
	if head == "main" and self.version == "master" then
		self.version = "main"
	end
	
	if head ~= self.version then
		print( "Fetch " .. self.url .."..." )
		local fetch_result = os.execute( base_command_line .. "fetch" )
		if not fetch_result then
			throw( "Failed to fetch '" .. self.url .. "' in '" .. self.export_path .. "'." )
		end

		print( "Checkout " .. self.url .."..." )
		local checkout_result = os.execute( base_command_line .. "checkout " .. self.version )
		if not checkout_result then
			throw( "Failed to checkout '" .. self.version .. "' for external '" .. self.url .. "'." )
		end
	end
end

function External:get_vcpkg_triplet( platform )
	local triplet_platform = iff( tiki.host_platform == Platforms.Windows, "windows", "linux" )
	--local triplet_config = iff( config ~= "Debug", "-release", "" )
	return platform .. "-" .. triplet_platform .. "-static" --.. triplet_config
end

function External:export_vcpkg( config, platform )
	local vcpkg_path = path.getdirectory( self.export_path )
	local vcpkg_ext = iff( tiki.host_platform == Platforms.Windows, ".exe", "" )
	local package_name = string.sub( self.url, 9, -1 )
	local triplet = self:get_vcpkg_triplet( platform )
	
	local command_line = path.join( vcpkg_path, "vcpkg" .. vcpkg_ext ) .. " install --vcpkg-root=\"" .. vcpkg_path .. "\" --triplet=".. triplet .. " " .. package_name
	local install_result = os.execute( command_line )
	if not install_result then
		throw( "Failed to install '" .. self.url .. "' to '" .. self.export_path .. "' with exit code " .. install_result .. "." )
	end
end

function External:load( additional_import_path )
	local tried_import_files = {}
	local import_file = path.join( self.export_path, "tiki.lua" )
	
	if not tiki.isfile( import_file ) then
		table.insert( tried_import_files, import_file );
		import_file = path.join( additional_import_path, self.file_path, "tiki.lua" )
		
		if not tiki.isfile( import_file ) then
			table.insert( tried_import_files, import_file );
			import_file = path.join( "externals", self.file_path, "tiki.lua" )
			
			if not tiki.isfile( import_file ) then
				table.insert( tried_import_files, import_file );
				import_file = path.join( additional_import_path, "externals", self.file_path, "tiki.lua" )
			end
		end
	end

	if not tiki.isfile( import_file ) then
		table.insert( tried_import_files, import_file );
		for _, file in ipairs( tried_import_files ) do
			print( "Not found: " .. file )
		end
		throw( "Could not find import file for '" .. self.url .. "'." )
	end

	print( "Load Module from " .. import_file )
	
	self.import_file = import_file
	self.import_func = tiki.loadfile( import_file )
	
	self.module = Module:new( self.file_path:gsub( "/", '_' ) )
	self.module:set_base_path( self.export_path )

	module = self.module
	tiki.external = self
	
	self.import_func()
	
	tiki.external = nil
	module = nil
	
	if self.type == ExternalTypes.Vcpkg then
		self.module.org_import_func = self.module.import_func
		
		self.module.import_func = function( project, solution )
			for _, platform in pairs( solution.platforms ) do
				local triplet = self:get_vcpkg_triplet( platform );
				
				self.module:add_include_dir( triplet .. "/include", nil, platform )
			end

			for _, platform in pairs( solution.platforms ) do
				local triplet = self:get_vcpkg_triplet( platform );
				
				for _, config in pairs( solution.configurations ) do
					self:export_vcpkg( config, platform )
				
					local config_dir = iff( config == "Debug", "/debug", "" )
					self.module:add_library_dir( triplet .. config_dir .. "/lib", config, platform )
				end
			end
			
			if self.module.org_import_func then
				self.module.org_import_func( project, solution )
			end
		end
	end
end

function find_external_module( url, importing_module )
	for _, external in ipairs( global_external_storage ) do
		if external.url == url then
			return external.module
		end
	end
	
	local external = External:new( url )
	external:export( importing_module.config.base_path )
	external:load( importing_module.config.base_path )
	
	return external.module
end
