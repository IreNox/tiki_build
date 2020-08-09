newoption{ trigger = "targets_action", description = "Action to simulate" }

function print_targets(sln)
	local vstudio_configs = premake.vstudio.buildconfigs( sln )

	local result = "[\n"
	for i,config in pairs( vstudio_configs ) do
		if i ~= 1 then
			result = result .. ", \n"
		end
		result = result .. "\t{ \"config\": \"" .. config[ "buildcfg" ] .. "\", \"platform\": \"" .. config[ "platform" ] .. "\" }"
	end
	result = result .. "\n]"

	print( result )
end

newaction {
   trigger     = "targets",
   description = "Print Targets",
   onsolution  = print_targets
}