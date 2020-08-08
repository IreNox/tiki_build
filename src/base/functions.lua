
function throw( text )
	print( debug.traceback() )
	error( text )
end

function iff( expr, when_true, when_false )
	if expr then
		return when_true
	else
		return when_false
	end
end

function class( init )
	local cls = init
	cls.__index = cls

	return cls
end

function class_instance( class )
	local new_instance = {}
	copy_instance( new_instance, class )
	setmetatable( new_instance, class )

	return new_instance
end

function vardump(value, depth, key)
	local linePrefix = ""
	local spaces = ""

	if key == "__index" then
	return
	end
	
	if key ~= nil then
		linePrefix = "["..key.."] = "
	end
	
	if depth == nil then
		depth = 0
	else
		depth = depth + 1
		for i=1, depth do spaces = spaces .. "  " end
	end
	
	if type(value) == 'table' then
		mTable = getmetatable(value)
		if mTable == nil then
			print(spaces ..linePrefix.."(table) ")
		else
			print(spaces .."(metatable) ")
				value = mTable
		end		
		for tableKey, tableValue in pairs(value) do
			vardump(tableValue, depth, tableKey)
		end
	elseif type(value)	== 'function' or 
		 type(value)	== 'thread' or 
		 type(value)	== 'userdata' or
		value			== nil
	then
		print(spaces..tostring(value))
	else
		print(spaces..linePrefix.."("..type(value)..") "..tostring(value))
	end
end

function table.uniq( array )
	local hash = {}
	
	local target = {}
	for _,val in ipairs( array ) do
		if not hash[ val ] then
			hash[ val ] = true
			target[ #target + 1 ] = val
		end
	end
	
	return target
end

function table.remove_value( table2, value )
	if type( table2 ) ~= "table" then
		throw( "not a table" )
	end
	
	local count = #table2
	for i = 0,count do
		if table2[ i ] == value then
			table.remove(table2, i )
			break
		end
	end
end

function table.length( table2 )
	local count = 0
	for _ in pairs( table2 ) do
		count = count + 1
	end
	
	return count
end

function copy_instance( target, source )
	for name,value in pairs( source ) do		
		if ( type( value ) == "table" and name ~= "__index" ) then
			target[ name ] = {}
			copy_instance( target[ name ], value )
		else
			target[ name ] = value
		end
	end
end

function import( fname, base_dir )
	if not base_dir then
		base_dir = os.getcwd()
	end

	local fileName = path.join( base_dir, fname, fname .. ".lua" )
	if not os.isfile( fileName ) then
		throw( "Can not import " .. fname .. " from " .. base_dir )
	end

	--print( "Import: " .. fileName )
	dofile( fileName )
end

function tiki.isfile( file_path )
	if tiki.files[ file_path ] then
		return true
	end
	
	local local_path = path.join( tiki.root_path, file_path )
	if os.isfile( local_path ) then
		return true
	end
	
	return os.isfile( file_path )
end

function tiki.loadfile( file_path )
	local file_func = nil
	if tiki.files[ file_path ] then
		file_func = assert( (loadstring or load)( tiki.files[ file_path ] ) )
	else
		local local_path = path.join( tiki.root_path, file_path )
		if os.isfile( local_path ) then
			file_func = assert( loadfile( local_path ) )
		else
			file_func = assert( loadfile( file_path ) )
		end
	end
	
	if not file_func then
		throw( "Failed to load script file: " .. file_path )
	end
	
	return file_func
end

function tiki.dofile( file_path )
	local file_func = tiki.loadfile( file_path )
	return file_func()
end

function get_config_dir( platform, configuration )
	if platform == nil or configuration == nil then
		throw( "get_config_dir: too few arguments." )
	end

	return _OPTIONS[ "to" ] .. "/" .. platform .. "/" .. configuration
end
