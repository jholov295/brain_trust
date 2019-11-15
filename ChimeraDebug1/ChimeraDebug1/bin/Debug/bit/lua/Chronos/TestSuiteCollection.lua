module( "Chronos.TestSuiteCollection", package.seeall )

function Chronos.TestSuiteCollection.new()
	return setmetatable( { }, Chronos.TestSuiteCollection )
end

function Chronos.TestSuiteCollection:Add( testSuite )
	table.insert( self, testSuite )
end

function Chronos.TestSuiteCollection:__index( key )
	local value = rawget( Chronos.TestSuiteCollection, key )
	if value ~= nil then
		return value
	end
	if key == "Passed" or key == "Pending" or key == "Failed" then
		return pl.tablex.filter( t, function( ts ) return ts.Status == key end )
	end
end

