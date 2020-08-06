
--
-- Use the release action to generate a single file containing all Lua scripts.
--

dofile("release.lua")

newaction {
	trigger     = "release",
	description = "Generate a single file for release",
	execute     = do_release
}