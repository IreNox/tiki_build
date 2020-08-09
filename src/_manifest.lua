
-- Manifest to describe files for release

return
{
	-- List of all script files. Order is important!
	embeded = {
		-- third pary
		"third_party/datadumper.lua",
	
		-- base files
		"base/globals.lua",
		"base/functions.lua",
		"base/configuration.lua",
		"base/configuration_set.lua",
		"base/extendable.lua",
		"base/external.lua",
		"base/module.lua",
		"base/project.lua",
		"base/solution.lua",
		"base/buildsteps.lua",
		"base/targets.lua"
	},
	dynamic = {
		"actions/**",
		"extensions/**",
		"externals/**"
	}
}
