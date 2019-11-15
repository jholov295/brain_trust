--- [Internal] TeamCityInfoPrinter is responsible for providing output for TeamCity builds.
module( "Chronos.TeamCityInfoPrinter", package.seeall )

---
-- @name Chronos.TeamCityInfoPrinter
-- @class table
Chronos.TeamCityInfoPrinter.__index = Chronos.TeamCityInfoPrinter

local escapes = {
		{ "|", "||" },
		{ "'", "|'" },
		{ "\n", "|n" },
		{ "\r", "|r" },
		{ "%]", "|]" }
	}

local function TeamCityEscape( s )
	for _, escape in ipairs( escapes ) do
		original, replacement = escape[ 1 ], escape[ 2 ]
		s = string.gsub( s, original, replacement )
	end
	return s
end

--- Creates a new Chronos.TeamCityInfoPrinter.
-- @return A new Chronos.TeamCityInfoPrinter
function new()
	return setmetatable( {}, Chronos.TeamCityInfoPrinter )
end

--- Called when a test run starts.
-- @param testSuites An array of Chronos.TestSuites that will be run
-- @param testCases An array of Chronos.TestCases that will be run
function Chronos.TeamCityInfoPrinter:TestRunStarted( testSuites, testCases )
end

--- Called when a test run ends.
-- @param testRunResults The Chronos.TestRunResults of the run
function Chronos.TeamCityInfoPrinter:TestRunEnded( testRunResults )
end

--- Called when a test suite starts.
-- @param testSuite The Chronos.TestSuite that will be run
function Chronos.TeamCityInfoPrinter:TestSuiteStarted( testSuite )
	io.stdout:write( "##teamcity[testSuiteStarted name='" .. TeamCityEscape( testSuite:GetName() ) .. "']\n" )
end

--- Called when a test suite ends.
-- @param testSuiteResults The Chronos.TestSuiteResults of the run
function Chronos.TeamCityInfoPrinter:TestSuiteEnded( testSuiteResults )
	io.stdout:write( "##teamcity[testSuiteFinished name='" .. TeamCityEscape( testSuiteResults.Name ) .. "']\n" )
end

function Chronos.TeamCityInfoPrinter:TestSuiteSaved()
	io.stdout:write( "Saving test suite...\n" )
end

--- Called when a test suite has one or more failures in Setup or Teardown.
function Chronos.TeamCityInfoPrinter:TestSuiteFailures( state, failures )
end

--- Called when a test case starts.
-- @param testCase The Chronos.TestCase that will be run
function Chronos.TeamCityInfoPrinter:TestCaseStarted( testCase )
	io.stdout:write( "##teamcity[testStarted name='" .. TeamCityEscape( testCase:GetName() ) .. "']\n" )
end

--- Called when a test case ends.
-- @param testCaseResults The Chronos.TestCaseResults of the run
function Chronos.TeamCityInfoPrinter:TestCaseEnded( testCaseResults )
	local name = TeamCityEscape( testCaseResults.Name )
	if testCaseResults.Failed then
		local message = ""
		local details = ""
		for _, failure in ipairs( testCaseResults.Failures or { } ) do
			if message == "" then
				message = failure.Message
			else
				message = message .. "\n" .. failure.Message
			end
			if details == "" then
				details = failure.StackTrace or ""
			end
		end
		message = TeamCityEscape( message )
		details = TeamCityEscape( details )
		io.stdout:write( "##teamcity[testFailed name='" .. name .. "' message='" .. message .. "' details='" .. details .. "']\n" )
	else
		if testCaseResults.Pending then
			io.stdout:write( "##teamcity[testIgnored name='" .. name .. "']\n" )
		end
		io.stdout:write( "##teamcity[testFinished name='" .. name .. "']\n" )
	end
end
