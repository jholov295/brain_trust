--- [Internal] DebugInfoPrinter is responsible for providing output when certain events occur during test execution when executed directly from Lua.
module( "Chronos.DebugInfoPrinter", package.seeall )

---
-- @name Chronos.DebugInfoPrinter
-- @class table
Chronos.DebugInfoPrinter.__index = Chronos.DebugInfoPrinter

--- Creates a new Chronos.DebugInfoPrinter.
-- @return A new Chronos.DebugInfoPrinter
function new()
	return setmetatable( {}, Chronos.DebugInfoPrinter )
end

--- Called when a test run starts.
-- @param testSuites An array of Chronos.TestSuites that will be run
-- @param testCases An array of Chronos.TestCases that will be run
function Chronos.DebugInfoPrinter:TestRunStarted( testSuites, testCases )
	io.stdout:write( "Debugging " .. #testCases .. " test cases in " .. #testSuites .. " test suites\n" )
end

--- Called when a test run ends.
-- @param testRunResults The Chronos.TestRunResults of the run
function Chronos.DebugInfoPrinter:TestRunEnded( testRunResults )
	io.stdout:write( "\n" )
	for _, status in ipairs { "Passed", "Failed", "Pending" } do
		io.stdout:write( status .. ": " .. #testRunResults.TestCases[ status ] .. " " )
	end
	io.stdout:write( "\n\n" )
end

--- Called when a test suite starts.
-- @param testSuite The Chronos.TestSuite that will be run
function Chronos.DebugInfoPrinter:TestSuiteStarted( testSuite )
	io.stdout:write( "\n" .. testSuite:GetName() .. "\n" )
end

--- Called when a test suite ends.
-- @param testSuiteResults The Chronos.TestSuiteResults of the run
function Chronos.DebugInfoPrinter:TestSuiteEnded( testSuiteResults )
end

--- Called when a test suite has one or more failures in Setup or Teardown.
function Chronos.DebugInfoPrinter:TestSuiteFailures( state, failures )
	for _, failure in ipairs( failures ) do
		io.stdout:write( " Failure in " .. state .. ":\n	" .. failure:ToLongString( 2 ) .. "\n" )
	end
end

--- Called when a test case starts.
-- @param testCase The Chronos.TestCase that will be run
function Chronos.DebugInfoPrinter:TestCaseStarted( testCase )
	io.stdout:write( " " .. testCase:GetName() .. "... " )
end

--- Called when a test case ends.
-- @param testCaseResults The Chronos.TestCaseResults of the run
function Chronos.DebugInfoPrinter:TestCaseEnded( testCaseResults )
	io.stdout:write( testCaseResults.Status .. "\n" )
	if testCaseResults.Failed then
		for _, failure in ipairs( testCaseResults.Failures ) do
			io.stdout:write( "	" .. failure:ToLongString( 4 ) .. "\n" )
		end
	end
end
