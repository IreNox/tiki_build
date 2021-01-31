newoption{ trigger = "quiet", description = "Hide all traces" }
newoption{ trigger = "to", description = "Location for generated project files. Default: ./build" }

Platforms = {
	Unknown	= 0,
	Android	= 1,
	Linux	= 2,
	MacOS	= 3,
	Windows	= 4
}

if tiki == nil then
	tiki = {}
end

if tiki.files == nil then
	tiki.files = {}
end

if tiki.root_path == nil then
	tiki.root_path = path.getabsolute( path.getdirectory( _SCRIPT ) )
end

if tiki.enable_unity_builds == nil then
	tiki.enable_unity_builds = true
end

if not _OPTIONS[ "to" ] then
	_OPTIONS[ "to" ] = 'build'
end

if tiki.generated_files_dir == nil then
	tiki.generated_files_dir = 'generated_files'
end

if tiki.externals_dir == nil then
	tiki.externals_dir = 'externals'
end

if tiki.executable_included == nil then
	local current_file = debug.getinfo(1,'S').source:match( "([^/]+)$" )
	tiki.executable_included = (current_file ~= "tiki_build.lua")
end

function tiki.get_platform_for_premake_string( platform )
	if platform == "android" then
		return Platforms.Android
	elseif platform == "windows" then
		return Platforms.Windows
	elseif platform == "bsd" or platform == "linux" or platform == "solaris" then
		return Platforms.Linux
	elseif platform == "macosx" then
		return Platforms.MacOS
	end
	
	return Platforms.Unknown
end

tiki.host_platform		= tiki.get_platform_for_premake_string( os.host() )
tiki.target_platform	= tiki.get_platform_for_premake_string( os.target() )

if tiki.svn_path == nil then
	tiki.svn_path = 'svn'
	if tiki.host_platform == Platforms.Windows then
		tiki.svn_path = tiki.svn_path .. '.exe'
	end
end

if tiki.git_path == nil then
	tiki.git_path = 'git'
	if tiki.host_platform == Platforms.Windows then
		tiki.git_path = tiki.git_path .. '.exe'
	end
end
