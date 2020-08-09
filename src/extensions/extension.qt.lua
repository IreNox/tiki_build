-- library/buildtools/extensions/extension.qt

qt_dir = "E:/Misc/Qt5.9.4/5.9.4/msvc2017_64" --TODO: find real path e.g. os.getenv("QTDIR")

local ui_script = path.getabsolute( path.join( path.getdirectory( _SCRIPT ), "actions/qt_ui.lua" ) )
local moc_script = path.getabsolute( path.join( path.getdirectory( _SCRIPT ), "actions/qt_moc.lua" ) )
local qrc_script = path.getabsolute( path.join( path.getdirectory( _SCRIPT ), "actions/qt_qrc.lua" ) )
local qrc_gen_script = path.getabsolute( path.join( path.getdirectory( _SCRIPT ), "actions/qt_qrc_gen.lua" ) )

function add_build_actions( module, pattern, prefix, ext, script )
	local full_pattern = path.join( module.config.base_path, pattern )
	local matches = os.matchfiles( full_pattern )

	if #matches == 0 then
		throw("[qt] '" .. pattern .. "' pattern matches no files.")
	end
	
	for j, filename in pairs( matches ) do
		local output_filename = prefix .. "_" .. path.getbasename( filename ) .. "." .. ext
	
		local step_data = {
			source_filename = path.join( module.config.base_path, filename ),
			output_filename = output_filename,
			qt_dir = qt_dir
		}
	
		module:add_pre_build_step( script, step_data )
		module:add_files( path.join( _OPTIONS[ "generated_files_dir" ], output_filename ), { optional = true } )
	end
end

function Module:add_ui_files( pattern )
	add_build_actions( self, pattern, "ui", "h", ui_script )
end

function Module:add_moc_files( pattern )
	add_build_actions( self, pattern, "moc", "cpp", moc_script )
end

function Module:add_qrc_files( pattern )
	add_build_actions( self, pattern, "rcc", "cpp", qrc_script )
end

function Module:add_qt_resources( pattern, prefix )
	local qrc_filename = "rcc_" .. prefix .. ".qrc"
	local qrc_fullpath = path.join( _OPTIONS[ "generated_files_dir" ], qrc_filename )
	
	local qrc_file = io.open( qrc_fullpath, "a" )
	qrc_file:close()
	
	local step_data = {
		prefix = prefix,
		source_pattern = path.join( self.config.base_path, pattern ),
		output_filename = qrc_fullpath
	}
	
	self:add_pre_build_step( qrc_gen_script, step_data )
	self:add_files( qrc_fullpath )

	add_build_actions( self, qrc_fullpath, "rcc", "cpp", qrc_script )
end