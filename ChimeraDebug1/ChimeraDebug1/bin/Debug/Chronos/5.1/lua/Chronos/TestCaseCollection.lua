module( "Chronos.TestCaseCollection", package.seeall )

function Chronos.TestCaseCollection.new()
	return setmetatable( { }, Chronos.TestCaseCollection )
end

function Chronos.TestCaseCollection:Add( testCase )
	table.insert( self, testCase )
end

function Chronos.TestCaseCollection:__index( key )
	local value = rawget( Chronos.TestCaseCollection, key )
	if value ~= nil then
		return value
	end
	local t = self
	if type( self ) == "userdata" then
		t = self:AsTable()
	end
	if key == "Passed" or key == "Pending" or key == "Failed" then
		return pl.tablex.filter( t, function( tc ) return tc.Status == key end )
	end
end

