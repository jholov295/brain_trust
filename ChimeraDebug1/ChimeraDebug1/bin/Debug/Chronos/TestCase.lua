--- Represents a test case.
-- <pre class="example">
-- testCase = Chronos.TestCase.new( "MyTestCase" )<br/>
-- testCase.Test = function() end<br/>
-- testCase.Setup = function() end<br/>
-- testCase.Teardown = function() end<br/>
-- </pre>
module( "Chronos.TestCase", package.seeall )

--- Contails details about the test case.
-- @name Chronos.TestCase
-- @class table
-- @field Anonymous True if the test case is anonymous.
-- @field Name The name of the test case. (Read-only)
-- @field Verison The version of the test case.
-- @field Test The test function. Does the actual execution of the test.
-- @field Setup The setup function. Called before the <code>Test</code> function.
-- @field Teardown The teardown function. Called after the <code>Test</code> function. This is called even if the <code>Test</code> fuction fails.
Chronos.TestCase.__index = Chronos.TestCase

--- Creates a new test case.
-- @param name The name of the test case. (Optional)
-- @param func The function that runs the actual test code. (Optional)
-- @return A new test case.
function new( name, func )
	local anonymous = false
	if not name then
		anonymous = true
		name = "(Anonymous Test Case)"
	end
	local testCase = { }
	setmetatable( testCase, Chronos.TestCase )
	testCase.Anonymous = anonymous
	testCase.Name = name
	testCase.Version = nil
	testCase.Setup = function() end
	testCase.Test = func
	testCase.Teardown = function() end
	local info = debug.getinfo( 2 )
	testCase.LineNumber = info.currentline
	testCase.SourceFile = info.short_src:gsub( "\\", "/" ) -- Always use posix separators
	return testCase
end

--- Gets the name of the test case.
-- Prefer this function rather than direct access, in case it is anonymous.
-- @return The name of the test case.
function Chronos.TestCase:GetName()
	if self.Anonymous then
		return "(Anonymous Test Case)"
	end
	return self.Name
end

--- Gets the version of the test case.
-- @return The version of the test case.
function Chronos.TestCase:GetVersion()
	return self.Version
end

--- Wraps test step execution so that failures are caught and recorded.
-- @param functionName The name of the function to execute, as a string.
-- @param testCaseRecorder A Chronos.TestCaseRecorder to use for recording the test case's execution.
function Chronos.TestCase:TryFunction( functionName, testCaseRecorder )
	local func = self[ functionName ]
	if not func then
		return
	end
	testCaseRecorder:SetState( functionName )
	local result, message = pcall( func )
	if not result then
		message = Chronos.ToString( message )
		Chronos.Actions.AddFailure( "Error: " .. message )
	end
	testCaseRecorder:ResetState()
end

--- Runs all steps of test case execution using a specified Chronos.TestCaseRecorder.
-- @param testCaseRecorder A Chronos.TestCaseRecorder to use for recording the test case's execution.
-- @return The Chronos.TestCaseRecorder that was passed in.
function Chronos.TestCase:Run( testCaseRecorder )
	self:TryFunction( "Setup", testCaseRecorder )
	self:TryFunction( "Test", testCaseRecorder )
	self:TryFunction( "Teardown", testCaseRecorder )
	return testCaseRecorder
end
