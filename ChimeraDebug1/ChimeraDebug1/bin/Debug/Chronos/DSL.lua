--- Chronos has a domain-specific language, or DSL, to help design expressive tests.
-- <pre class="example">
-- TestSuite "My Test Suite"<br/>
-- {<br/>
-- &nbsp; Version = "Thu Jul  1 14:42:39 2010",<br/>
-- <br/>
-- &nbsp; Setup = function() -- Optional suite-level setup block.<br/>
-- &nbsp; &nbsp; DoStuff()<br/>
-- &nbsp; end,<br/>
-- <br/>
-- &nbsp; Teardown = function() -- Optional suite-level teardown block.<br/>
-- &nbsp; &nbsp; DoStuff()<br/>
-- &nbsp; end,<br/>
-- <br/>
-- &nbsp; EachSetup = function() -- Optional shared case-level setup block.<br/>
-- &nbsp; &nbsp; DoStuff()<br/>
-- &nbsp; end,<br/>
-- <br/>
-- &nbsp; EachTeardown = function() -- Optional shared case-level teardown block.<br/>
-- &nbsp; &nbsp; DoStuff()<br/>
-- &nbsp; end,<br/>
-- <br/>
-- &nbsp; TestCase "My Test Case"<br/>
-- &nbsp; {<br/>
-- &nbsp; Version = 1.0,<br/>
-- <br/>
-- &nbsp; &nbsp; Setup = function() -- Optional case-level setup block.<br/>
-- &nbsp; &nbsp; &nbsp; DoStuff()<br/>
-- &nbsp; &nbsp; end,<br/>
-- <br/>
-- &nbsp; &nbsp; Teardown = function() -- Optional case-level teardown block.<br/>
-- &nbsp; &nbsp; &nbsp; DoStuff()<br/>
-- &nbsp; &nbsp; end,<br/>
-- <br/>
-- &nbsp; &nbsp; Test = function() -- Explicitly set the function to clarify that this is the test run block.<br/>
-- &nbsp; &nbsp; &nbsp; Check( true )<br/>
-- &nbsp; &nbsp; end<br/>
-- <br/>
-- &nbsp; &nbsp; -- OR<br/>
-- <br/>
-- &nbsp; &nbsp; function() -- Implicitly set the test run block with a bare function.<br/>
-- &nbsp; &nbsp; &nbsp; Check( true )<br/>
-- &nbsp; &nbsp; end<br/>
-- &nbsp; }<br/>
-- }<br/>
-- </pre>
module( "Chronos.DSL", package.seeall )

---	Looks if a single value is in a table.
--	@param tbl Table to seach in.
--	@param value String of the value to find in tbl.
local function iContainsEntry( tbl, value )
	for _, val in ipairs( tbl ) do
		if type( val ) == "table" then
			if true == iContainsEntry( val, value ) then
				return true
			end
		else
			if val == value then
				return true
			end
		end
	end

	return false
end


--- Starts generating a test suite.
-- @param name The name of the test suite.
-- @return A function that takes a table of options to finish generating the test suite.
-- @usage local testSuite = TestSuite "My Test Suite"<br/>
-- {<br/>
-- &nbsp; Version = "Thu Jul  1 14:42:39 2010",<br/>
-- <br/>
-- &nbsp; Setup = function()<br/>
-- &nbsp; &nbsp; -- Do Setup<br/>
-- &nbsp; end,<br/>
-- <br/>
-- &nbsp; Teardown = function()<br/>
-- &nbsp; &nbsp; -- Do Teardown<br/>
-- &nbsp; end,<br/>
-- <br/>
-- &nbsp; EachSetup = function()<br/>
-- &nbsp; &nbsp; -- Do EachSetup<br/>
-- &nbsp; end,<br/>
-- <br/>
-- &nbsp; EachTeardown = function()<br/>
-- &nbsp; &nbsp; -- Do EachTeardown<br/>
-- &nbsp; end,<br/>
-- <br/>
-- &nbsp; TestCase "My Test Case"<br/>
-- &nbsp; {<br/>
-- &nbsp; &nbsp; -- Describe Test Case<br/>
-- &nbsp; }<br/>
-- }
function TestSuite( name )
	local testSuite = Chronos.TestSuite.new( name )
	local info = debug.getinfo( 2 )
	testSuite.LineNumber = info.currentline
	testSuite.SourceFile = info.short_src:gsub( "\\", "/" ) -- Always use posix separators
	return function( options )
		local validKeys =
		{
			Setup = { "function" },
			Teardown = { "function" },
			EachSetup = { "function" },
			EachTeardown = { "function" },
			Version = { "string", "number" }
		}
		-- Check to make sure only the correct types are used.
		for key, value in pairs( options ) do
			if not tonumber( key ) then
				-- Check if it is a valid key value
				if not validKeys[ key ] then
					error( string.format( "TestSuite %q has an invalid key %q", name, key ), 2 )
				end
				-- Check type of the value
				if not iContainsEntry( validKeys[ key ], type( value ) ) then
					error( string.format( "TestSuite %q has key %q with an invalid type (%s), only %s allowed.", name, key, type( value ), table.concat( validKeys[ key ], " or " ) ), 2 )
				end
				testSuite[ key ] = value
			end
		end
		-- Adds the testCase to the metatable
		local function addTestCase( testCase )
			if type( testCase ) ~= "table" then
				error( tostring( testCase ) .. " is not a test case or array of test cases." )
			end
			if getmetatable( testCase ) == Chronos.TestCase then
				testSuite:AddTestCase( testCase )
			else
				for _, testCase in ipairs( testCase ) do
					addTestCase( testCase )
				end
			end
		end
		for _, testCase in ipairs( options ) do
			addTestCase( testCase )
		end
		-- This is included to facilitate debugging. If we are running the test suite directly, we want to run it right away.
		if not _G.CHRONOS_RUN_MANUALLY then
			Chronos.Run { testSuite }
		end
		return testSuite
	end
end

--- Starts generating a test case.
-- @param name The name of the test case.
-- @return A function that takes a table of options to finish generating the test case.
-- @usage local testCase = TestCase "My Test Case"<br/>
-- {<br/>
-- &nbsp; Version = 1.0,<br/>
-- <br/>
-- &nbsp; Setup = function()<br/>
-- &nbsp; &nbsp; -- Do Setup<br/>
-- &nbsp; end,<br/>
-- <br/>
-- &nbsp; Teardown = function()<br/>
-- &nbsp; &nbsp; -- Do Teardown<br/>
-- &nbsp; end,<br/>
-- <br/>
-- &nbsp; Test = function()<br/>
-- &nbsp; &nbsp; -- Run Test<br/>
-- &nbsp; end<br/>
-- <br/>
-- &nbsp; -- OR<br/>
-- <br/>
-- &nbsp; function()<br/>
-- &nbsp; &nbsp; -- Run Test<br/>
-- &nbsp; end<br/>
-- }
-- </pre>
function TestCase( name )
	local testCase = Chronos.TestCase.new( name )
	local info = debug.getinfo( 2 )
	testCase.LineNumber = info.currentline
	testCase.SourceFile = info.short_src:gsub( "\\", "/" ) -- Always use posix separators
	return function( options )
		local validKeys =
		{
			Setup = { "function" },
			Test = { "function" },
			Teardown = { "function" },
			Version = { "string", "number" }
		}
		-- Check to make sure only the correct types are used.
		for key, value in pairs( options ) do
			if not tonumber( key ) then
				if not validKeys[ key ] then
					error( string.format( "TestCase %q has an invalid key %q", name, key ), 2 )
				end
				if not iContainsEntry( validKeys[ key ], type( value ) ) then
					error( string.format( "TestCase %q has key %q with an invalid type (%s), only %s allowed.", name, key, type( value ), table.concat( validKeys[ key ], " or " ) ), 2 )
				end
				testCase[ key ] = value
			end
		end
		for _, test in ipairs( options ) do
			if type( test ) ~= "function" then
				error( tostring( test ) .. " is not a function", 2 )
			end
			testCase.Test = test
		end
		return testCase
	end
end

GlobalExport( "TestSuite", "TestCase" )
