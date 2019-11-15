--- Chronos provides two facilities for formatting values as hex.
-- One of these is explicit: Call ToHexString() with the value you want to convert
-- to hex, along with any options you want to pass to bit.tohex().
-- The other option is to use StartHex() and EndHex(). This is more declarative,
-- and will format an infinite number of values inline.
-- <pre class="example">
-- local hexA = ToHexString( integerValueA )<br/>
-- local hexB = ToHexString( integerValueB )<br/>
-- local decimalValue = integerValueC<br/>
-- print( "Value A: " .. hexA .. " Value B: " .. hexB .. " Value C: " .. decimalValue )<br/>
-- -- OR<br/>
-- print( StartHex() .. "Value A: " .. integerValueA .. " Value B: " .. integerValueB<br/>
-- &nbsp; &nbsp; .. EndHex() .. " Value C: " .. integerValueC )<br/>
-- -- Both print:<br/>
-- -- Value A: 0x11e234af Value B: 0x24db2cce Value C: 89
-- </pre>
module( "Chronos.Hex", package.seeall )

StartHexFormatter = StartHexFormatter or { }
StartHexFormatter.__index = StartHexFormatter

EndHexFormatter = EndHexFormatter or { }
EndHexFormatter.__index = EndHexFormatter

function StartHexFormatter.new()
	return setmetatable( { }, StartHexFormatter )
end

function StartHexFormatter.__concat( left, right )
	if getmetatable( right ) == EndHexFormatter then
		return right.Value
	end
	error( "Missing EndHex" )
end

function EndHexFormatter.new( value, digits )
	value = value or ""
	return setmetatable( { Value = value, Digits = digits }, EndHexFormatter )
end

function EndHexFormatter.__concat( left, right )
	if getmetatable( left ) == EndHexFormatter then
		return EndHexFormatter.new( left.Value .. right )
	elseif getmetatable( right ) == EndHexFormatter then
		return EndHexFormatter.new( ToHexString( left, right.Digits ) .. right.Value )
	end
end

--- Marks the beginning of a hex-formatted stream.
-- Any numbers concatenated with a hex-formatted stream will be turned
-- into strings representing their hex values.
function StartHex()
	return StartHexFormatter.new()
end

--- Marks the end of a hex-formatted stream.
-- Any numbers concatenated with a hex-formatted stream will be turned
-- into strings representing their hex values.
-- @param digits The number of digits to display, defaults to 8. Negative for uppercase digits.
function EndHex( digits )
	return EndHexFormatter.new( "", digits )
end

--- Converts a value to its hex representation.
-- @param x Value to be converted.
-- @param digits The number of digits to display, defaults to 8. Negative for uppercase digits.
function ToHexString( x, digits )
	if type( x ) == "table" then
		local s = "{"
		for _, v in ipairs( x ) do
			if s ~= "{" then
				s = s .. ","
			end
			s = s .. ToHexString( v, digits )
		end
		for k, v in pairs( x ) do
			if type( k ) ~= "number" or k > #x then
				if s ~= "{" then
					s = s .. ","
				end
				s = s .. k .. "=" .. ToHexString( v, digits )
			end
		end
		s = s .. "}"
		return s
	end
	local n = tonumber( x )
	if n then
		return "0x" .. bit.tohex( x, unpack{ digits } )
	end
	return tostring( x )
end

GlobalExport(
	"ToHexString",
	"StartHex",
	"EndHex"
)
