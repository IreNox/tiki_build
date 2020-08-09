
ExternalTypes = {
	SVN		= 'svn',
	Git		= 'git',
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
	if url_protocol == "git" then
		external_new.type = ExternalTypes.Git
	elseif url_protocol == "https" and external_new.url:endswith( ".git" ) then
		external_new.type = ExternalTypes.Git
	elseif url_protocol == "svn" then
		external_new.type = ExternalTypes.SVN
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

	local builtin_rmdir = os.rmdir
	function bla(p)
		-- recursively remove subdirectories
		local dirs = os.matchdirs(p .. "/*")
		for _, dname in ipairs(dirs) do
			print(dname)
			bla(dname)
		end

		-- remove any files
		local files = os.matchfiles(p .. "/*")
		for _, fname in ipairs(files) do
			print(fname)
			print( 'bla' )
			print( os.remove(fname) )
		end

		-- remove this directory
		builtin_rmdir(p)
	end

function External:export()
	local externals_dir = path.getabsolute( path.join( _OPTIONS[ "to" ], tiki.externals_dir ) )
	self.export_path = path.join( externals_dir, self.file_path )
	
	if self.type == ExternalTypes.SVN then
		self:export_svn()
	elseif self.type == ExternalTypes.Git then
		self:export_git()
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
		local command_line = tiki.git_path .. " clone " .. self.url .. " " .. self.export_path
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

function External:load()
	local import_file = path.join( self.export_path, "tiki.lua" )
	if not os.isfile( import_file ) then
		import_file = path.join( "externals", self.file_path, "tiki.lua" )
	end

	print( "Load Module from " .. import_file )

	if not tiki.isfile( import_file ) then
		throw( "Could not find import file for '" .. self.url .. "'." )
	end
	
	self.import_file = import_file
	self.import_func = tiki.loadfile( import_file )
	
	self.module = Module:new( self.file_path:gsub( "/", '_' ) )
	self.module:set_base_path( self.export_path )

	module = self.module
	tiki.external = self
	
	self.import_func()
	
	tiki.external = nil
	module = nil
end

function find_external_module( url )
	for _, external in ipairs( global_external_storage ) do
		if external.url == url then
			return external.module
		end
	end
	
	local external = External:new( url )
	external:export()
	external:load()
	
	return external.module
	--throw( "Could not find external with URL '" .. url .. "'. Please register before add adding it." )
end
