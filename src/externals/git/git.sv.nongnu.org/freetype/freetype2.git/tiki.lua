-- git/git.sv.nongnu.org/freetype/freetype2.git

local freetype_project = Project:new(
	"freetype",
	{ "x32", "x64" },
	{ "Debug", "Release" },
	ProjectTypes.StaticLibrary
)

freetype_project.module.module_type = ModuleTypes.FilesModule

freetype_project:add_files( path.join( path.getdirectory( _SCRIPT ), "zerror.c" ) )

freetype_project:add_include_dir( "include" )

freetype_project:add_files( "include/*.h" )

freetype_project:add_files( "src/autofit/autofit.c" )
freetype_project:add_files( "src/base/ftbase.c" )
freetype_project:add_files( "src/base/ftbbox.c" )
freetype_project:add_files( "src/base/ftbitmap.c" )
freetype_project:add_files( "src/base/ftfstype.c" )
freetype_project:add_files( "src/base/ftgasp.c" )
freetype_project:add_files( "src/base/ftglyph.c" )
freetype_project:add_files( "src/base/ftgxval.c" )
freetype_project:add_files( "src/base/ftinit.c" )
freetype_project:add_files( "src/base/ftmm.c" )
freetype_project:add_files( "src/base/ftotval.c" )
freetype_project:add_files( "src/base/ftpatent.c" )
freetype_project:add_files( "src/base/ftpfr.c" )
freetype_project:add_files( "src/base/ftstroke.c" )
freetype_project:add_files( "src/base/ftsynth.c" )
freetype_project:add_files( "src/base/ftsystem.c" )
freetype_project:add_files( "src/base/fttype1.c" )
freetype_project:add_files( "src/base/ftwinfnt.c" )
freetype_project:add_files( "src/bdf/bdf.c" )
freetype_project:add_files( "src/cache/ftcache.c" )
freetype_project:add_files( "src/cff/cff.c" )
freetype_project:add_files( "src/cid/type1cid.c" )
freetype_project:add_files( "src/gzip/ftgzip.c" )
freetype_project:add_files( "src/lzw/ftlzw.c" )
freetype_project:add_files( "src/pcf/pcf.c" )
freetype_project:add_files( "src/pfr/pfr.c" )
freetype_project:add_files( "src/psaux/psaux.c" )
freetype_project:add_files( "src/pshinter/pshinter.c" )
freetype_project:add_files( "src/psnames/psmodule.c" )
freetype_project:add_files( "src/raster/raster.c" )
freetype_project:add_files( "src/sfnt/sfnt.c" )
freetype_project:add_files( "src/smooth/smooth.c" )
freetype_project:add_files( "src/truetype/truetype.c" )
freetype_project:add_files( "src/type1/type1.c" )
freetype_project:add_files( "src/type42/type42.c" )
freetype_project:add_files( "src/winfonts/winfnt.c" )

if tiki.platform == Platforms.Windows then
	freetype_project:add_library_file( "Kernel32.lib", "Debug" )
	freetype_project:add_files( "builds/windows/ftdebug.c" )
end

freetype_project:set_define( "FT2_BUILD_LIBRARY", "1" )
freetype_project:set_define( "FT_DEBUG_LEVEL_ERROR", "1" )
freetype_project:set_define( "FT_DEBUG_LEVEL_TRACE", "1" )
freetype_project:set_define( "_CRT_SECURE_NO_WARNINGS" )

module:add_include_dir( "include" )

if tiki.platform == Platforms.Windows then
	module:add_library_file( "Kernel32.lib", "Debug" )
end

module.import_func = function( project, solution )
	project:add_project_dependency( freetype_project )
	solution:add_project( freetype_project )
end
