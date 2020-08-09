
Extendable = class{
	new_hooks = {},
	pre_finalize_hooks = {},
	post_finalize_hooks = {}
}

function Extendable:new()
	return class_instance( self )
end

function Extendable:add_new_hook( hook_func )
	table.insert( self.new_hooks, hook_func )
end

function Extendable:add_pre_finalize_hook( hook_func )
	table.insert( self.pre_finalize_hooks, hook_func )
end

function Extendable:add_post_finalize_hook( hook_func )
	table.insert( self.post_finalize_hooks, hook_func )
end

function Extendable:execute_new_hook( ... )
	for _, hook in ipairs( self.new_hooks ) do
		hook( ... )
	end
end

function Extendable:execute_pre_finalize_hook( ... )
	for _, hook in ipairs( self.pre_finalize_hooks ) do
		hook( ... )
	end
end

function Extendable:execute_post_finalize_hook( ... )
	for _, hook in ipairs( self.post_finalize_hooks ) do
		hook( ... )
	end
end
