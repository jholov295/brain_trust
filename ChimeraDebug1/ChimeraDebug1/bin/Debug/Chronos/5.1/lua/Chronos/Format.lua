module( "Chronos", package.seeall )

function ToString( arg )
	if not rawget( getmetatable( arg ) or { }, "__tostring" ) then
		if type( arg ) == "table" then
			return pl.pretty.write( arg, "" )
		end
		if type( arg ) == "userdata" then
			local s = "{"
			local first = true
			for k, v in pairs( arg ) do
				if not first then
					s = s .. ","
				end
				first = false
				local okay, valString = pcall( ToString, v )
				if not okay then
					valString = "<cycle>"
				end
				s = s .. k .. "=" .. valString
			end
			return s .. "}"
		end
	end
	return tostring( arg )
end

function Format( formatString, ... )
	local args = { ... }
	for i, arg in ipairs( args ) do
		args[ i ] = ToString( arg )
	end
	return string.format( formatString, unpack( args ) )
end

function FormatHex( formatString, ... )
	local args = { ... }
	for i, arg in ipairs( args ) do
		args[ i ] = ToHexString( arg )
	end
	return string.format( formatString, unpack( args ) )
end

GlobalExport( "ToString" )
