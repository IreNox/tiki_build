newoption{ trigger = "to", description = "Location for generated project files. Default: ./build" }

Platforms = {
	Unknown	= 0,
	Windows	= 1,
	Linux	= 2,
	MacOS	= 3
}

if not tiki then
	tiki = {}
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

if os.get() == "windows" then
	tiki.platform = Platforms.Windows
elseif os.get() == "bsd" or os.get() == "linux" or os.get() == "solaris" then
	tiki.platform = Platforms.Linux
elseif os.get() == "macosx" then
	tiki.platform = Platforms.MacOS
else
	tiki.platform = Platforms.Unknown
end
