--- Contains information about a test suite execution.
module( "Chronos.TestSuiteResults", package.seeall )

---
-- @name Chronos.TestSuiteResults
-- @class table
-- @field StartTime The start time of the test run.
-- @field EndTime The end time of the test run.
-- @field Time The total time of the test run.
-- @field Anonymous True if the test suite is anonymous.
-- @field Name The name of the test suite.
-- @field Version The version of the test suite.
-- @field LineNumber The number of the line on which the test suite was defined.
-- @field SourceFile The file in which the test suite was defined.
-- @field Status "Passed" "Pending" or "Failed"
-- @field Passed True if the suite passed.
-- @field Pending True if the suite is pending.
-- @field Failed True if the suite failed.
-- @field Steps Contains both the actions and failures of the suite's execution, in order.
-- @field Steps.Setup Contains steps from Setup.
-- @field Steps.Idle Contains steps from Idle.
-- @field Steps.Teardown Contains steps from Teardown.
-- @field Actions Contains actions of the suite's executed actions.
-- @field Actions.Setup Contains actions from Setup.
-- @field Actions.Idle Contains actions from Idle.
-- @field Actions.Teardown Contains actions from Teardown.
-- @field Failures Contains failures of the suite's failed actions.
-- @field Failures.Setup Contains failures from Setup.
-- @field Failures.Idle Contains failures from Idle.
-- @field Failures.Teardown Contains failures from Teardown.
-- @field TestCases An array of Chronos.TestCaseResults. (Also indexed by name: TestCases["My Test Case"])
-- @field TestCases.Passed An array of Chronos.TestCaseResults whose status is Passed.
-- @field TestCases.Pending An array of Chronos.TestCaseResults whose status is Pending.
-- @field TestCases.Failed An array of Chronos.TestCaseResults whose status is Failed.
Metatable = "Chronos.TestSuiteResults"

--- Creates a new Chronos.TestSuiteResults.
-- @param testSuite The test suite.
-- @param saveResults {boolean} if true save the results to the filesystem as it runs.
-- @return A new Chronos.TestSuiteResults.
function new( testSuite, saveResults )
	local now = Chronos.Time.Now()
	local testSuiteResults = setmetatable( { }, Chronos.TestSuiteResults )
	if saveResults then
		testSuiteResults = Chronos.FileTable.new( nil, "Chronos.TestSuiteResults" )
	end

	testSuiteResults.Steps		= Chronos.StepCollection.new()
	testSuiteResults.TestCases	= Chronos.TestCaseCollection.new()
	testSuiteResults.Name		= testSuite.Name
	testSuiteResults.Version	= testSuite.Version
	testSuiteResults.LineNumber	= testSuite.LineNumber
	testSuiteResults.SourceFile	= testSuite.SourceFile
	testSuiteResults.Status		= "Pending"
	testSuiteResults.StartTime	= now
	testSuiteResults.EndTime	= now

	return testSuiteResults
end

--- Adds a failure to the Failures and Failures[ state ] arrays.
-- Will mark the results as failed.
-- @param state The state during which the failure occurred.
-- @param failure The failure.
function Chronos.TestSuiteResults:AddFailure( state, failure )
	self.Steps:Add( state, failure )
	if not self.Failed then
		self.Status = "Failed"
	end
end

--- Adds an action to the Actions and Actions[ state ] arrays.
-- Will mark the results as passed if they would otherwise remain pending.
-- @param state The state during which the action occurred.
-- @param action The action.
function Chronos.TestSuiteResults:AddAction( state, action )
	self.Steps:Add( state, action )
	if self.Pending then
		self.Status = "Passed"
	end
end

function Chronos.TestSuiteResults:__newindex( key, val )
	if key == "Passed" or key == "Pending" or key == "Failed" then
		error( "Trying to write '" .. key .. "' to TestSuiteResults. TestSuiteResults only allows read-only access to '".. key .. "'." )
	else
		-- Set the values as normal.
		rawset( self, key, val )
	end
end

function Chronos.TestSuiteResults:__index( key, val )
	if rawget( Chronos.TestSuiteResults, key ) then
		return rawget( Chronos.TestSuiteResults, key )
	end

	if key == "Passed" or key == "Pending" or key == "Failed" then
		return self.Status == key
	end

	if key == "Time" then
		return self.EndTime - self.StartTime
	end

	if key == "Actions" or key == "Failures" then
		return self.Steps[ key ]
	end
end

