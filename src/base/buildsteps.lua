if _ACTION == 'buildsteps'
	newoption{ trigger = "script", description = "Script to load" }
	newoption{ trigger = "project", description = "Name of the Project" }
end

if _ACTION == 'buildsteps' and not _OPTIONS[ 'script' ] then
	error("No script specified.")
end

function is_build_required( source_file, target_file )
	if not source_file then
		throw( "is_build_required: no source_file specified." )
	end

	if not target_file then
		throw( "is_build_required: no target_file specified." )
	end
	
	if not os.isfile( source_file ) then
		throw( "is_build_required: " .. source_file .. " doesn't esists." )
	end
	
	if os.isfile( target_file ) then
		if os.stat( source_file ).mtime > os.stat( target_file ).mtime then
			return true
		end
	else
		return true
	end
	
	return false
end

function execute_build_steps()
	local config = {
		project_name = _OPTIONS[ "project" ],
		build_path = path.getabsolute( "." ),
		output_path = path.getabsolute( _OPTIONS[ "to" ] )		
	}

	local script_file = path.join( config.build_path, _OPTIONS[ "script" ] )
	if not os.isfile( script_file )	then
		throw( "Script file not found at " .. script_file )
	end
	
	local build_actions = dofile( script_file )
	for i, action in pairs( build_actions ) do
		if not tiki.isfile( action.script )	then
			throw( "Action script file not found at " .. action.script )
		end
	
		local action_function = tiki.dofile( action.script )
		if type( action_function ) ~= "function" then
			throw( "Script in " .. action.script .. " doesn't contain a function." )
		end
		
		config.base_path = action.base_path
		
		action_function( action.data, config )
	end
end

newaction {
   trigger     = "buildsteps",
   description = "Execute Build Steps",
   execute     = execute_build_steps
}
