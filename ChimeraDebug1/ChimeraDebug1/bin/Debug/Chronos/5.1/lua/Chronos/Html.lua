--- For use in reports.
module( "Chronos.Html", package.seeall )

--- Escapes a given string such that it will not disrupt HTML markup.
-- @param str The string to escape.
-- @return An escaped string.
function Escape( str )
	str = tostring( str )
	str = string.gsub( str, "<", "&lt;" )
	str = string.gsub( str, ">", "&gt;" )
	str = string.gsub( str, "\n", "<br/>" )
	return str
end
