--- Represents a test suite.
-- Test suites are the top-level component of your test definitions. They can have a name and several test cases.
-- <pre class="example">
-- testSuite = Chronos.TestSuite.new( "My Test Suite" )<br/>
-- testSuite:AddTestCase( someTestCase )<br/>
-- myTestCase = testSuite.TestCases[ "My Test Case" ] -- Find test case by name.<br/>
-- testSuite.Setup = function() end<br/>
-- testSuite.Teardown = function() end<br/>
-- testSuite.EachSetup = function() end<br/>
-- testSuite.EachTeardown = function() end<br/>
-- </pre>
-- <b>Notes</b>:
-- <ul>
--   <li>Gets a specific test case by name using the '[ ]' operator on the <code>TestCases</code>.<br/> <pre class="example">myTestCase = testSuite.TestCases[ "My Test Case" ]</pre></li>
-- </ul>
module( "Chronos.TestSuite", package.seeall )

--- Contains the details of the test suite. The test suite contains the actuals tests, TestCases.
-- @class table
-- @name TestSuite
-- @field Anonymous True if the test suite is anonymous.
-- @field Name The name of the test suite.
-- @field Version The version of the test suite.
-- @field TestCases An array of <code>Chronos.TestCases</code>.
-- @field Setup The setup function. Called before any <code>Chronos.TestCases</code>.
-- @field Teardown The teardown function. Called after the all the <code>Chronos.TestCases</code> are finished. This is called even if there are any failures in the <code>Chronos.TestCases</code>.
-- @field EachSetup The each setup function. Called before each <code>Chronos.TestCase</code>.
-- @field EachTeardown The each teardown function. Called after each <code>Chronos.TestCase</code>. This is called even if there are any failures in the <code>Chronos.TestCase</code>.
Chronos.TestSuite.__index = Chronos.TestSuite

--- Creates a new test suite.
-- Test suites are automatically added to the run queue when created.
-- @param name The name of the test suite. (Optional)
-- @return A new test suite.
function new( name )
	local anonymous = false
	if not name then
		anonymous = true
	end
	local info = debug.getinfo( 2 )
	local testSuite = {
		Anonymous = anonymous,
		Name = name,
		Version = nil,
		TestCases = { },
		Setup = function() end,
		Teardown = function() end,
		EachSetup = function() end,
		EachTeardown = function() end,
		LineNumber = info.currentline,
		SourceFile = info.short_src:gsub( "\\", "/" ) -- Always use posix separators
	}

	setmetatable( testSuite, Chronos.TestSuite )
	if Chronos.CurrentTestAccumulator then
		Chronos.CurrentTestAccumulator:AddTestSuite( testSuite )
	end
	return testSuite
end

--- Gets the name of the test suite.
-- Prefer this function rather than direct access, in case it is anonymous.
-- @return The name of the test suite.
function Chronos.TestSuite:GetName()
	if self.Anonymous then
		return "(Anonymous Test Suite)"
	end
	return self.Name
end

--- Gets the version of the test suite.
-- @return The version of the test suite.
function Chronos.TestSuite:GetVersion()
	return self.Version
end

--- Adds a test case to the suite.
-- @param testCase The test case to add.
function Chronos.TestSuite:AddTestCase( testCase )
	table.insert( self.TestCases, testCase )
	if not testCase.Anonymous then
		self.TestCases[ testCase.Name ] = testCase
	end
end

--- Wraps test step execution so that failures are caught and recorded.
-- @param functionName The name of the function to execute, as a string.
-- @param testSuiteRecorder A Chronos.TestSuiteRecorder to use for recording the test suite's execution.
function Chronos.TestSuite:TryFunction( functionName, testSuiteRecorder )
	local func = self[ functionName ]
	if not func then
		return
	end
	testSuiteRecorder:SetState( functionName )
	local result, message = pcall( func )
	if not result then
		local failure = Chronos.Actions.AddFailure( "Error: " .. message )
	end
	local failureCount = #testSuiteRecorder.Results.Failures[ functionName ]
	if (functionName == "Setup" or functionName == "Teardown") and failureCount > 0 then
		local infoPrinter = Chronos.CurrentInfoPrinter
		if infoPrinter then
			infoPrinter:TestSuiteFailures( functionName, testSuiteRecorder.Results.Failures[ functionName ] )
		end
	end
	testSuiteRecorder:ResetState()
end

--- Runs all steps of test suite execution using a specified Chronos.TestSuiteRecorder.
-- @param testSuiteRecorder A Chronos.TestSuiteRecorder to use for recording the test suite's execution.
-- @return The Chronos.TestSuiteRecorder that was passed in.
function Chronos.TestSuite:Run( testSuiteRecorder )
	self:TryFunction( "Setup", testSuiteRecorder )
	for _, testCase in ipairs( self.TestCases ) do
		local testCaseRecorder = testSuiteRecorder:StartCase( testCase )
		self:TryFunction( "EachSetup", testCaseRecorder )
		testCaseRecorder = testCase:Run( testCaseRecorder )
		self:TryFunction( "EachTeardown", testCaseRecorder )
		testSuiteRecorder:SaveCase( testCaseRecorder:EndCase() )
	end
	self:TryFunction( "Teardown", testSuiteRecorder )
	return testSuiteRecorder
end

--- Runs all steps of test suite execution with a single test case, using a specified Chronos.TestSuiteRecorder.
-- @param testSuiteRecorder A Chronos.TestSuiteRecorder to use for recording the test suite's execution.
-- @param testCase The test case to run in the context of the test suite.
-- @return The Chronos.TestSuiteRecorder that was passed in.
function Chronos.TestSuite:RunCase( testSuiteRecorder, testCase )
	self:TryFunction( "Setup", testSuiteRecorder )
	local testCaseRecorder = testSuiteRecorder:StartCase( testCase )
	self:TryFunction( "EachSetup", testCaseRecorder )
	testCaseRecorder = testCase:Run( testCaseRecorder )
	self:TryFunction( "EachTeardown", testCaseRecorder )
	testSuiteRecorder:SaveCase( testCaseRecorder:EndCase() )
	self:TryFunction( "Teardown", testSuiteRecorder )
	return testSuiteRecorder
end
