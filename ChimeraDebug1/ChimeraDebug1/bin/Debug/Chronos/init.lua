require "bit"
pl = {}
 pl.dir = require "pl.dir"
pl.path = require "pl.path"
 pl.stringx = require "pl.stringx"
 pl.tablex = require "pl.tablex"
 pl.pretty = require "pl.pretty"
 pl.utils = require "pl.utils"

--~ local dir = require "pl.dir"
--~ local path = require "pl.path"
--~ local stringx = require "pl.stringx"
--~ local tablex = require "pl.tablex"
--~ local pretty = require "pl.pretty"
require "socket"
require "Chronos.LuaPP"
require "Chronos.FileTable"
require "Chronos.GlobalExport"
require "Chronos.Time"
require "Chronos.Take"
require "Chronos.Hex"
require "Chronos.Format"
require "Chronos.XML"
require "Chronos.TestSuiteCollection"
require "Chronos.TestCaseCollection"
require "Chronos.StepCollection"
require "Chronos.TestRunResults"
require "Chronos.TestSuiteResults"
require "Chronos.TestCaseResults"
require "Chronos.TestSuite"
require "Chronos.TestCase"
require "Chronos.TestAccumulator"
require "Chronos.TestCaseRecorder"
require "Chronos.TestSuiteRecorder"
require "Chronos.TestRunRecorder"
require "Chronos.Html"
require "Chronos.Csv"
require "Chronos.DeviceComm"
require "Chronos.Actions"
require "Chronos.Action"
require "Chronos.Failure"
require "Chronos.DSL"
require "Chronos.Config"
require "Chronos.InfoPrinter"
require "Chronos.DebugInfoPrinter"
require "Chronos.TeamCityInfoPrinter"
require "Chronos.Version"

-- This is to prevent chaos when the user requires "chronos" while internal code requires "Chronos",
-- leading to double inclusion and overwriting global state, causing Bad Things to happen.
package.loaded.Chronos = Chronos
package.loaded.chronos = Chronos

--- Chronos is a Lua framework for performing system tests using command sets through DeviceComm.
-- <pre class="example">
-- require "Chronos"<br/>
-- <br/>
-- local deviceComm<br/>
-- <br/>
-- local settings =<br/>
-- {<br/>
-- &nbsp; Port = "COM3",<br/>
-- &nbsp; Baud = 38400,<br/>
-- &nbsp; ReadLoopback = "true",<br/>
-- &nbsp; AssertRTS = "true"<br/>
-- }<br/>
-- <br/>
-- TestSuite "My Excellent Test Suite"<br/>
-- {<br/>
-- &nbsp; Setup = function()<br/>
-- &nbsp; &nbsp; deviceComm = DeviceComm.new( "MyCommandset.xml" )<br/>
-- &nbsp; &nbsp; deviceComm:Initialize( "Serial", settings )<br/>
-- &nbsp; end,<br/>
-- <br/>
-- &nbsp; Teardown = function()<br/>
-- &nbsp; &nbsp; deviceComm:Do( "AllDone" )<br/>
-- &nbsp; end,<br/>
--<br/>
-- &nbsp; EachSetup = function()<br/>
-- &nbsp; &nbsp; deviceComm:Do( "Unlock" )<br/>
-- &nbsp; end,<br/>
-- <br/>
-- &nbsp; TestCase "My Radical Test Case"<br/>
-- &nbsp; {<br/>
-- &nbsp; &nbsp; Setup = function()<br/>
-- &nbsp; &nbsp; &nbsp; deviceComm:Do( "LetMeMessWithStuff" )<br/>
-- &nbsp; &nbsp; end,<br/>
-- <br/>
-- &nbsp; &nbsp; function()<br/>
-- &nbsp; &nbsp; &nbsp; local result = deviceComm:Do( "MessingWithTheMirror", { Param1 = 0xdeadbeef } )<br/>
-- &nbsp; &nbsp; &nbsp; CheckEqual( 0x05, result.Out.ReturnValue, "Bad Things happened!" )<br/>
-- &nbsp; &nbsp; end<br/>
-- &nbsp; },<br/>
-- <br/>
-- &nbsp; TestCase "My Tubular Test Case"<br/>
-- &nbsp; {<br/>
-- &nbsp; &nbsp; Teardown = function()<br/>
-- &nbsp; &nbsp; &nbsp; deviceComm:Do( "ResetValues" )<br/>
-- &nbsp; &nbsp; end,<br/>
-- <br/>
-- &nbsp; &nbsp; Test = function()<br/>
-- &nbsp; &nbsp; &nbsp; local result = deviceComm:Do( "ChangeSomeValues", { Value1 = 0x11, Value2 = 0x22, Value3 = 0x33 } )<br/>
-- &nbsp; &nbsp; &nbsp; CheckSequenceHex( { 0x11, 0x22, 0x33 }, result.Out.SetValues )<br/>
-- &nbsp; &nbsp; &nbsp; Check( result.Out.AwesomeFlag, StartHex() .. "Awesome flag was not set," ..<br/>
-- &nbsp; &nbsp; &nbsp; &nbsp; " so I'm going to print some stuff in hex: " .. 123 .. " and " .. 45 .. EndHex() ..<br/>
-- &nbsp; &nbsp; &nbsp; &nbsp; " but this is in decimal: " .. 67 )<br/>
-- &nbsp; &nbsp; end<br/>
-- &nbsp; }<br/>
-- }<br/>
-- </pre>
module( "Chronos", package.seeall )

-- Meta information
_COPYRIGHT		= "Copyright (C) 2010 Gentex Corporation"
_DESCRIPTION	= "A testing framework for Lua"
_VERSION		= Version

CurrentConfig			= Config.Default
CurrentTestAccumulator	= nil
CurrentInfoPrinter		= nil

ActiveTestCaseRecorder	= nil
ActiveTestSuiteRecorder	= nil
ActiveTestRunRecorder	= nil

--- Gets the active test recorder that an action should use, preferring a Chronos.TestCaseRecorder to a Chronos.TestSuiteRecorder.
-- @return The active test recorder, or nil if there is none.
function GetActiveRecorder()
	return Chronos.ActiveTestCaseRecorder or Chronos.ActiveTestSuiteRecorder
end

--- Runs a given array of test suites.
-- @param testSuites The test suites to run.
-- @return The Chronos.TestRunResults of the run
function Run( testSuites, saveResults )
	testSuites = testSuites or { }
	local testCases = { }
	for _, testSuite in ipairs( testSuites ) do
		for _, testCase in ipairs( testSuite.TestCases ) do
			table.insert( testCases, testCase )
		end
	end
	local recorder = Chronos.ActiveTestRunRecorder or Chronos.TestRunRecorder.new( saveResults )
	recorder:StartRun( testSuites, testCases )
	for _, testSuite in ipairs( testSuites ) do
		recorder:SaveSuite( testSuite:Run( recorder:StartSuite( testSuite ) ):EndSuite() )
	end
	return recorder:EndRun()
end

--- Runs all test suites stored in the current test accumulator.
-- @return The Chronos.TestRunResults of the run
function RunAccumulated( saveResults )
	return Run( Chronos.CurrentTestAccumulator.TestSuites, saveResults )
end

--- Runs a single test case within the context of a given test suite.
-- @param testSuite The test suite to use to provide the setup/teardown facilities for the test case.
-- @param testCase The test case to run.
-- @return The Chronos.TestRunResults of the run
function RunSuiteCase( testSuite, testCase, saveResults )
	local testSuites = { testSuite }
	local testCases = { testCase }
	local recorder = Chronos.ActiveTestRunRecorder or Chronos.TestRunRecorder.new( saveResults )
	recorder:StartRun( testSuites, testCases )
	recorder:SaveSuite( testSuite:RunCase( recorder:StartSuite( testSuite ), testCase ):EndSuite() )
	return recorder:EndRun()
end

--- Generates a report and returns it as a string.
-- Report templates will have access to all of the elements of the test results, as well as the Chronos module and anything in the global table.
-- @param results A TestRunResults table returned by a call to Chronos.Run().
-- @param templatePath The path to the template.
-- @return The body of the generated template as a string
function GenerateReport( results, templatePath )
	if not results then
		error( "No results specified", 0 )
	end
	if not templatePath then
		error( "No template path specified", 0 )
	end
	local templateFile = io.open( templatePath )
	if not templateFile then
		error( "Failed to open template file \"" .. templatePath .. "\"", 0 )
	end
	local template = templateFile:read( "*a" )
	templateFile:close()
	local mt =
	{
		__index = function( self, key )
			local value = results[ key ]
			if value ~= nil then
				return value
			end
			return _G[ key ]
		end
	}
	local environment = setmetatable( { }, mt )
	return LuaPP.preprocess( { input = template, output = "string", lookup = environment, strict = false } )
end

--- Renders a report to a file.
-- @param results A TestRunResults table returned by a call to Chronos.Run().
-- @param templatePath The path to the template.
-- @param outputPath The path to the desired output location.
function RenderReport( results, templatePath, outputPath )
	if not outputPath then
		error( "No output path specified", 0 )
	end
	local generatedReport, message = GenerateReport( results, templatePath )
	if not generatedReport then
		error( message, 0 )
	end
	-- This is something we would like to have, so subdirectories are created automatically,
	-- but pl.dir.makepath is currently broken on all platforms
	pcall( pl.dir.makepath, pl.path.dirname( outputPath ) )
	local outputFile = io.open( outputPath, "w" )
	if not outputFile then
		error( "Failed to open output file \"" .. outputPath .. "\"", 0 )
	end
	outputFile:write( generatedReport )
	outputFile:close()
end

--- Provides a safe way to get the username of the shell running the script.
-- Most useful in reports.
-- @return The username of the current user, or "User" if no information is available.
function GetUserName()
	return ( os.getenv( "USER" ) or os.getenv( "USERNAME" ) ) or "User"
end

-- Hook for running Chronos files directly.
if not _G.CHRONOS_RUN_MANUALLY then
	_G.DEBUG_TRACEBACK_NO_PAUSE		= true
	Chronos.CurrentConfig			= Chronos.Config.Default
	Chronos.CurrentTestAccumulator	= Chronos.TestAccumulator.new()
	Chronos.CurrentInfoPrinter		= Chronos.DebugInfoPrinter.new()
end
