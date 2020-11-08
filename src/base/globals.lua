newoption{ trigger = "quiet", description = "Hide all traces" }
newoption{ trigger = "to", description = "Location for generated project files. Default: ./build" }

Platforms = {
	Unknown	= 0,
	Android	= 1,
	Linux	= 2,
	MacOS	= 3,
	Windows	= 4
}

if not tiki then
	tiki = {}
end

if not tiki.files then
	tiki.files = {}
end

if not tiki.root_path then
	tiki.root_path = path.getabsolute( path.getdirectory( _SCRIPT ) )
end

if not tiki.enable_unity_builds then
	tiki.enable_unity_builds = true
end

if not _OPTIONS[ "to" ] then
	_OPTIONS[ "to" ] = 'build'
end

if not tiki.generated_files_dir then
	tiki.generated_files_dir = 'generated_files'
end

if not tiki.externals_dir then
	tiki.externals_dir = 'externals'
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

if not tiki.svn_path then
	tiki.svn_path = 'svn'
	if tiki.host_platform == Platforms.Windows then
		tiki.svn_path = tiki.svn_path .. '.exe'
	end
end

if not tiki.git_path then
	tiki.git_path = 'git'
	if tiki.host_platform == Platforms.Windows then
		tiki.git_path = tiki.git_path .. '.exe'
	end
end
