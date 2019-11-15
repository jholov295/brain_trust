module( "Chronos", package.seeall )

--- Like select, but takes the first n arguments rather than arguments after n.
-- @param n The number of arguments to return
-- @param ... The arguments to take
-- @return The first n arguments passed in for ...
function Take( n, ... )
	local r = { }
	local args = { ... }
	for i = 1, n do
		table.insert( r, args[ i ] )
	end
	return unpack( r )
end
