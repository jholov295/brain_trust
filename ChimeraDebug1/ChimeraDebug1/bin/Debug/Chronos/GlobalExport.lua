--- Exports the given symbols into the global namespace _G.
-- @param ... A list of symbols to export.
function GlobalExport( ... )
	local symbols = { ... }
	for _, symbol in ipairs( symbols ) do
		_G[ symbol ] = getfenv( 2 )[ symbol ]
	end
end
