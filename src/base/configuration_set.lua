

ConfigurationSet = class{
	base_path = "",
	global_config = nil,
	platforms = {},
	configurations = {},
	ConfigurationSets = {} 
};

function ConfigurationSet:new()
	local ConfigurationSet_new = class_instance( self );
	ConfigurationSet_new.global_config	= Configuration:new();

	if tiki.external then
		ConfigurationSet_new.base_path		= tiki.external.export_path;
	else
		ConfigurationSet_new.base_path		= os.getcwd();
	end

	return ConfigurationSet_new;
end

function ConfigurationSet:get_config( configuration, platform )
	if ( ( configuration ~= nil and type( configuration ) ~= "string" ) or ( platform ~= nil and type( platform ) ~= "string" ) ) then
		throw "[ConfigurationSet:get_config] Invalid args";
	end

	if ( configuration ~= nil and platform ~= nil ) then
		if not self.ConfigurationSets[ platform ] then
			self.ConfigurationSets[ platform ] = { configurations = {} };
		end
		if not self.ConfigurationSets[ platform ].configurations[ configuration ] then
			self.ConfigurationSets[ platform ].configurations[ configuration ] = Configuration:new();
		end

		return self.ConfigurationSets[ platform ].configurations[ configuration ];
	elseif ( configuration ~= nil and platform == nil ) then
		if not self.configurations[ configuration ] then
			self.configurations[ configuration ] = Configuration:new();
		end

		return self.configurations[ configuration ];
	elseif ( configuration == nil and platform ~= nil ) then
		if not self.platforms[ platform ] then
			self.platforms[ platform ] = Configuration:new();
		end

		return self.platforms[ platform ];
	else
		return self.global_config;
	end

	return nil;
end

function ConfigurationSet:set_base_path( base_path )
	if path.isabsolute( base_path ) then
		self.base_path = base_path;
	else
		self.base_path = path.join( tiki.root_path, base_path );
	end
end

function ConfigurationSet:set_define( name, value, configuration, platform )
	self:get_config( configuration, platform ):set_define( name, value, self.base_path );
end

function ConfigurationSet:set_flag( name, configuration, platform )
	self:get_config( configuration, platform ):set_flag( name, self.base_path );
end

function ConfigurationSet:set_setting( setting, value, configuration, platform )
	self:get_config( configuration, platform ):set_setting( setting, value );
end

function ConfigurationSet:add_include_dir( include_dir, configuration, platform )
	self:get_config( configuration, platform ):add_include_dir( include_dir, self.base_path );
end

function ConfigurationSet:add_library_dir( library_dir, configuration, platform )
	self:get_config( configuration, platform ):add_library_dir( library_dir, self.base_path );
end

function ConfigurationSet:add_library_file( library_filename, configuration, platform )
	self:get_config( configuration, platform ):add_library_file( library_filename );
end

function ConfigurationSet:add_pre_build_step( step_script, step_data, configuration, platform )
	self:get_config( configuration, platform ):add_pre_build_step( step_script, step_data, self.base_path );
end

function ConfigurationSet:add_post_build_step( step_script, step_data, configuration, platform )
	self:get_config( configuration, platform ):add_post_build_step( step_script, step_data, self.base_path );
end