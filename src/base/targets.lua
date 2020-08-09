newoption{ trigger = "targets_action", description = "Action to simulate" }

function print_targets( wks )
	local result = "[\n"
	
	local i = 1
	for cfg in premake.workspace.eachconfig(wks) do
		if cfg.buildcfg ~= "Project" then
			if i ~= 1 then
				result = result .. ", \n"
			end
			
			local platform = premake.vstudio.solutionPlatform(cfg)
			result = result .. "\t{ \"config\": \"" .. cfg.buildcfg .. "\", \"platform\": \"" .. platform .. "\" }"
			
			i = i + 1
		end
	end
	result = result .. "\n]"

	quietf( result )
end

newaction {
   trigger		= "targets",
   description	= "Print Targets",
   onWorkspace	= print_targets
}