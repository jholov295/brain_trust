--- [Internal] InfoPrinter is responsible for providing output when certain events occur during test execution.
module( "Chronos.InfoPrinter", package.seeall )

---
-- @name Chronos.InfoPrinter
-- @class table
Chronos.InfoPrinter.__index = Chronos.InfoPrinter

--- Creates a new Chronos.InfoPrinter.
-- @return A new Chronos.InfoPrinter
function new()
	return setmetatable( {}, Chronos.InfoPrinter )
end

--- Called when a test run starts.
-- @param testSuites An array of Chronos.TestSuites that will be run
-- @param testCases An array of Chronos.TestCases that will be run
function Chronos.InfoPrinter:TestRunStarted( testSuites, testCases )
	io.stdout:write( "Running " .. #testCases .. " test cases in " .. #testSuites .. " test suites\n" )
end

--- Called when a test run ends.
-- @param testRunResults The Chronos.TestRunResults of the run
function Chronos.InfoPrinter:TestRunEnded( testRunResults )
	io.stdout:write( "\n" )
	for _, status in ipairs { "Passed", "Failed", "Pending" } do
		io.stdout:write( status .. ": " .. #testRunResults.TestCases[ status ] .. " " )
	end
	io.stdout:write( "\n" )
end

--- Called when a test suite starts.
-- @param testSuite The Chronos.TestSuite that will be run
function Chronos.InfoPrinter:TestSuiteStarted( testSuite )
	io.stdout:write( "\n" .. testSuite:GetName() .. "\n" )
end

--- Called when a test suite ends.
-- @param testSuiteResults The Chronos.TestSuiteResults of the run
function Chronos.InfoPrinter:TestSuiteEnded( testSuiteResults )
end

function Chronos.InfoPrinter:TestSuiteSaved()
	io.stdout:write( "Saving test suite...\n" )
end

--- Called when a test suite has one or more failures in Setup or Teardown.
function Chronos.InfoPrinter:TestSuiteFailures( state, failures )
	for _, failure in ipairs( failures ) do
		io.stdout:write( " Failure in " .. state .. ":\n	" .. failure:ToLongString( 2 ) .. "\n" )
	end
end

--- Called when a test case starts.
-- @param testCase The Chronos.TestCase that will be run
function Chronos.InfoPrinter:TestCaseStarted( testCase )
	io.stdout:write( " " .. testCase:GetName() .. "... " )
end

--- Called when a test case ends.
-- @param testCaseResults The Chronos.TestCaseResults of the run
function Chronos.InfoPrinter:TestCaseEnded( testCaseResults )
	io.stdout:write( testCaseResults.Status .. "\n" )
	if testCaseResults.Failed then
		for _, failure in ipairs( testCaseResults.Failures ) do
			io.stdout:write( "	" .. failure:ToLongString( 4 ) .. "\n" )
		end
	end
end

