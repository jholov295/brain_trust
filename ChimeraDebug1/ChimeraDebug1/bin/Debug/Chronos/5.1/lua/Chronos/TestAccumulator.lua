--- [Internal] TestAccumulator is responsible for storing defined tests.
-- <b>Notes</b>:
-- <ul>
-- 	<li>Gets a specific test suite by name using the '[ ]' operator on the <code>TestSuites</code> table.<br/>
--		<pre class="example">local ts = Chronos.CurrentTestAccumulator.TestSuites[ "My Test Suite" ]</pre></li>
-- </ul>
module( "Chronos.TestAccumulator", package.seeall )

---	Table that stores the defined test suites.
-- @name Chronos.TestAccumulator
-- @class table
-- @field TestSuites An array of Chronos.TestSuites
Chronos.TestAccumulator.__index = Chronos.TestAccumulator

--- Creates a new Chronos.TestAccumulator.
-- @return A new Chronos.TestAccumulator
function new()
	local testAccumulator = { }
	testAccumulator.TestSuites = { }
	return setmetatable( testAccumulator, Chronos.TestAccumulator )
end

--- Adds a Chronos.TestSuite to self.TestSuites.
-- @param testSuite The Chronos.TestSuite to add
function Chronos.TestAccumulator:AddTestSuite( testSuite )
	if getmetatable( testSuite ) ~= Chronos.TestSuite then
		error( tostring( testSuite ) .. " is not a test suite" )
	end
	table.insert( self.TestSuites, testSuite )
	-- Add them to the table by name as well. Aid getting them by name.
	if not testSuite.Anonymous then
		self.TestSuites[ testSuite.Name ] = testSuite
	end
end

--- Clears all loaded Chronos.TestSuites from self.
function Chronos.TestAccumulator:Clear()
	self.TestSuites = { }
end
