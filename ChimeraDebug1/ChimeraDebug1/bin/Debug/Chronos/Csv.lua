--- For use in reports.
module( "Chronos.Csv", package.seeall )

--- Escapes a given string such that it will be properly interpreted in most CSV viewers.
-- @param str The string to escape.
-- @return An escaped string.
function Escape( str )
	str = string.gsub( str, "\"", "'" )
	if string.find( str, "," ) then
		str = "\"" .. str .. "\""
	end
	return str
end
