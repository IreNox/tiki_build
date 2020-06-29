
function throw( text )
	print( "Exception: " .. text );
	--print( debug.traceback() );
	error();
end

function iff( expr, when_true, when_false )
	if expr then
		return when_true
	else
		return when_false
	end
end

function class( init )
	local cls = init;
	cls.__index = cls;

	return cls;
end

function class_instance( class )
	local new_instance = {};
	copy_instance( new_instance, class );
	setmetatable( new_instance, class );

	return new_instance;
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

function io.exists( file_name )
	local file_handle = io.open( file_name, "r" );
	if file_handle then
		file_handle:close();
		return true;
	end
	return false;
end

function io.readfile( file_name )
	local file_handle = io.open( file_name, "r" );
	local result = "";
	if file_handle then
		result = file_handle:read( "*a" );
		file_handle:close();
	end
	return result;
end

function io.writefile( file_name, content )
	local file_handle = io.open( file_name, "w" );
	if file_handle then
		file_handle:write( content );
		file_handle:close();
		return true;
	end
	return false;
end

function table.flatten( array_array )
	if type( array_array ) ~= "table" then
		throw( "table.flatten: invalid argument" );
	end

	local target = {}
	for i,array in pairs( array_array ) do
		for j,val in pairs( array ) do
			target[ #target + 1 ] = val;
		end
	end

	return target;
end

function table.uniq( array )
	local hash = {};
	
	local target = {};
	for _,val in ipairs( array ) do
	   if not hash[ val ] then
		   hash[ val ] = true;
		   target[ #target + 1 ] = val;
	   end
	end
	
	return target;
end

function table.index_of( table, object )
	local result = -1;
 
	if type( table ) ~= "table" then
		throw( "not a table" );
	end
	
	local count = #table;
	for i = 0,count do
		if table[ i ] == object then
			result = i;
			break;
		end
	end
	
	return result;	
end

function table.contains_value( table2, value )
	if type( table2 ) ~= "table" then
		throw( "not a table" );
	end
	
	local count = #table2;
	for i = 0,count do
		if table2[ i ] == value then
			return true;
		end
	end
	
	return false
end

function table.remove_value( table2, value )
	if type( table2 ) ~= "table" then
		throw( "not a table" );
	end
	
	local count = #table2;
	for i = 0,count do
		if table2[ i ] == value then
			table.remove(table2, i );
			break;
		end
	end
end

function copy_instance( target, source )
	for name,value in pairs( source ) do		
		if ( type( value ) == "table" and name ~= "__index" ) then
			target[ name ] = {};
			copy_instance( target[ name ], value );
		else
			target[ name ] = value;
		end
	end
end

function import( fname, base_dir )
	if not base_dir then
		base_dir = os.getcwd()
	end

	local fileName = path.join( base_dir, fname, fname .. ".lua" );
	if not os.isfile( fileName ) then
		throw( "Can not import " .. fname .. " from " .. base_dir );
	end

	--print( "Import: " .. fileName );
	dofile( fileName );
end

function get_config_dir( platform, configuration )
	if ( platform == nil or configuration == nil ) then
		throw( "get_config_dir: too few arguments." );
	end

	return _OPTIONS[ "to" ] .. "/" .. platform .. "/" .. configuration;
end
