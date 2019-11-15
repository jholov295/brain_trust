local rawnext = next

function _G.next( t, k )
	if t == nil then return end
	local m = getmetatable( t )
	local n = m and m.__next or rawnext
	return n( t, k )
end

function _G.pairs( t )
	local m = getmetatable( t ) or { }
	if m.__pairs then
		t = m.__pairs( t )
	end
	return next, t, nil
end

local function _ipairs( t, var )
	var = var + 1
	local err, value = pcall( function() return t[var] end )	-- Make it metamethod safe.
	if err == false or value == nil then return end
	return var, value
end

function ipairs( t )
	if t == nil then
		error( "Invalid argument to ipairs: " .. tostring( t ), 2 )
	end
	return _ipairs, t, 0
end

local rawinsert = table.insert

function table.insert( t, p, v )
	if v == nil then
		v = p
		p = #t + 1
	end
	local m = getmetatable( t )
	local i = m and m.__insert or rawinsert
	return i( t, p, v )
end

module( "Chronos.FileTable", package.seeall )

local function newFileTable( path, userMetatableString )
	if path and pl.path.extension( path ) ~= ".table" then
		path = path .. ".table"
	end
	userMetatableString = userMetatableString or "nil"
	local userMetatable = assert( loadstring( "return " .. userMetatableString ) )()
	local proxy = newproxy( true )
	local metatable = getmetatable( proxy )
	for _, metamethod in ipairs { "__index", "__newindex", "__len", "__gc", "__next", "__insert", "__tostring", "__pairs" } do
		metatable[ metamethod ] = Chronos.FileTable[ metamethod ]
	end
	metatable.Path = path
	metatable.Metatable = userMetatable or { }
	metatable.MetatableString = userMetatableString
	metatable.Contents = setmetatable( { }, { __mode = "v" } )
	metatable.Subtables = { }
	metatable.SuppressGC = not path
	metatable.GCReferences = { }
	return proxy
end

local function sanitizeFilename( filename )
	return string.gsub( filename, "[/\\?:|]", "" )
end

function new( path, userMetatableString )
	local proxy = newFileTable( path, userMetatableString )
	Save( proxy )
	return proxy
end

function Chronos.FileTable.Load( path, userMetatableString )
	if path and pl.path.extension( path ) ~= ".table" then
		path = path .. ".table"
	end
	local proxy = newFileTable( path, userMetatableString )
	local metatable = getmetatable( proxy )

	for _, name in ipairs { "Contents", "Subtables" } do
		local wholePath = path .. "/" .. name
		if pl.path.exists( wholePath ) then
			local file = io.open( wholePath )
			local wholeString = file:read( "*a" )
			file:close()
			local readContents = pl.pretty.read( wholeString )
			for k, v in pairs( readContents or { } ) do
				metatable[ name ][ k ] = v
			end
		end
	end

	local wholePath = path .. "/Metatable"
	if pl.path.exists( wholePath ) then
		local file = io.open( wholePath )
		metatable.MetatableString = file:read( "*a" )
		file:close()
		metatable.Metatable = assert( loadstring( "return " .. metatable.MetatableString ) )() or { }
	end

	return proxy
end

local function Write( t )
	local s = "{"
	for k, v in pairs( t ) do
		local typ = type( v )
		if typ == "string" or typ == "number" or typ == "boolean" then
			if type( k ) == "number" then
				s = s .. "[" .. k .. "]="
			else
				s = s .. string.format( "[%q]=", k )
			end
			if typ == "string" then
				s = s .. string.format( "%q", v )
			else
				s = s .. tostring( v )
			end
			s = s .. ","
		end
	end
	s = s .. "}"
	return s
end

function Chronos.FileTable:Save()
	local metatable = getmetatable( self )
	if not metatable.Path then
		return
	end
	if not pl.path.exists( metatable.Path ) then
		pl.dir.makepath( metatable.Path )
	end

	for k, v in pairs {
			Contents = Write( metatable.Contents ),
			Subtables = Write( metatable.Subtables ),
			Metatable = metatable.MetatableString
		} do
		local file = io.open( metatable.Path .. "/" .. k, "w" )
		if not file then
			error( "Could not save file " .. metatable.Path .. "/" .. k, 2 )
		end
		file:write( v )
		file:close()
	end
end

function Chronos.FileTable:GetContents( key )
	local contents = getmetatable( self ).Contents
	if key then
		return contents[ key ]
	end
	return contents
end

function Chronos.FileTable:GetMetatable()
	return getmetatable( self ).Metatable
end

function Chronos.FileTable:GetPath()
	return getmetatable( self ).Path
end

function Chronos.FileTable:SetPath( path )
	local metatable = getmetatable( self )
	local wasNil = metatable.Path == nil
	if pl.path.extension( path ) ~= ".table" then
		path = path .. ".table"
	end
	metatable.Path = path
	for subtable, subtablePath in pairs( metatable.Subtables ) do
		SetPath( self[ subtable ], path .. "/" .. subtablePath )
	end
	if wasNil then
		RestoreGC( self )
	end
	Save( self )
end

function Chronos.FileTable:GetSubtables()
	return getmetatable( self ).Subtables
end

function Chronos.FileTable:SetSubtable( key, value )
	getmetatable( self ).Subtables[ key ] = value
end

function Chronos.FileTable:SuppressGC()
	local metatable = getmetatable( self )
	if metatable.SuppressGC then
		return
	end
	metatable.SuppressGC = true
	for subtable, _ in pairs( metatable.Subtables ) do
		local t = self[ subtable ]
	end
end

function Chronos.FileTable:RestoreGC()
	local metatable = getmetatable( self )
	if metatable.Path == nil or not metatable.SuppressGC then
		return
	end
	metatable.SuppressGC = false
	metatable.GCReferences = { }
end

function Chronos.FileTable:AsTable()
	local t = { }
	local metatable = getmetatable( self )
	for k, v in pairs( metatable.Contents ) do
		if type( v ) ~= "userdata" and type( v ) ~= "table" then
			t[ k ] = v
		end
	end
	for subtable, _ in pairs( metatable.Subtables ) do
		t[ subtable ] = self[ subtable ]
	end
	return setmetatable( t, GetMetatable( self ) )
end

function Chronos.FileTable:__index( key )
	local metatable = getmetatable( self )
	local value

	-- Try looking in Contents table
	value = rawget( metatable.Contents, key )
	if value ~= nil then
		return value
	end

	-- Try looking in subtables
	if metatable.Subtables[ key ] then
		local keyPath = metatable.Path .. "/" .. metatable.Subtables[ key ]
		value = Chronos.FileTable.Load( keyPath )
		rawset( metatable.Contents, key, value )
	end
	if value ~= nil then
		return value
	end

	-- Try Chronos.FileTable
	value = rawget( Chronos.FileTable, key )
	if value ~= nil then
		return value
	end

	-- Try user's metatable
	local __index = metatable.Metatable.__index
	if type( __index ) == "function" then
		value = __index( self, key )
	elseif type( __index ) == "table" then
		value = rawget( __index, key )
	end
	if value ~= nil then
		return value
	end
end

function Chronos.FileTable:__newindex( key, value )
	local metatable = getmetatable( self )
	local valueType = type( value )

	-- Table?
	if valueType == "table" then
		local valueMetatable = getmetatable( value ) or { }
		local t = value
		local keyPath = sanitizeFilename( key )
		local fileTablePath = nil
		if metatable.Path then
			fileTablePath = metatable.Path .. "/" .. keyPath
		end
		value = Chronos.FileTable.new( fileTablePath, valueMetatable._NAME )
		for k, v in pairs( t ) do
			value[ k ] = v
		end
		SetSubtable( self, key, keyPath )
		if metatable.SuppressGC then
			metatable.GCReferences[ key ] = value
		end
	end

	-- FileTable?
	if valueType == "userdata" then
		local keyPath = sanitizeFilename( key )
		if metatable.Path then
			SetPath( value, metatable.Path .. "/" .. keyPath )
		end
		SetSubtable( self, key, keyPath )
		if metatable.SuppressGC then
			metatable.GCReferences[ key ] = value
		end
	end

	rawset( metatable.Contents, key, value )
	Chronos.FileTable.Save( self )
end

function Chronos.FileTable:__len()
	return #Chronos.FileTable.AsTable( self )
end

function Chronos.FileTable:__insert( position, value )
	self[ position ] = value
end

function Chronos.FileTable:__tostring()
	return tostring( Chronos.FileTable.AsTable( self ) )
end

function Chronos.FileTable:__pairs()
	return Chronos.FileTable.AsTable( self )
end

