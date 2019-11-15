--- Contains information about a test case execution.
module( "Chronos.TestCaseResults", package.seeall )

---
-- @name TestCaseResults
-- @class table
-- @field Anonymous True if the test case is anonymous.
-- @field Name The name of the test case.
-- @field Version The version of the test case.
-- @field LineNumber The number of the line on which the test case was defined.
-- @field SourceFile The file in which the test case was defined.
-- @field Status "Passed" "Pending" or "Failed"
-- @field Passed True if the test passed.
-- @field Pending True if the test is pending.
-- @field Failed True if the test failed.
-- @field Steps Contains both the actions and failures of the test's execution, in order.
-- @field Steps.Setup Contains steps from Setup.
-- @field Steps.EachSetup Contains steps from EachSetup.
-- @field Steps.Test Contains steps from Test.
-- @field Steps.EachTeardown Contains steps from EachTeardown.
-- @field Steps.Teardown Contains steps from Teardown.
-- @field Actions Contains actions of the test's executed actions.
-- @field Actions.Setup Contains actions from Setup.
-- @field Actions.EachSetup Contains actions from EachSetup.
-- @field Actions.Test Contains actions from Test.
-- @field Actions.EachTeardown Contains actions from EachTeardown.
-- @field Actions.Teardown Contains actions from Teardown.
-- @field Failures Contains failures of the test's failed actions.
-- @field Failures.Setup Contains failures from Setup.
-- @field Failures.EachSetup Contains failures from EachSetup.
-- @field Failures.Test Contains failures from Test.
-- @field Failures.EachTeardown Contains failures from EachTeardown.
-- @field Failures.Teardown Contains failures from Teardown.

--- Creates a new Chronos.TestCaseResults.
-- @param testCase The test case.
-- @return A new Chronos.TestCaseResults.
function new( testCase, saveResults )
	local now = Chronos.Time.Now()
	local testCaseResults = setmetatable( { }, Chronos.TestCaseResults )
	if saveResults then
		testCaseResults = Chronos.FileTable.new( nil, "Chronos.TestCaseResults" )
	end

	testCaseResults.Steps		= Chronos.StepCollection.new()
	testCaseResults.Name		= testCase.Name
	testCaseResults.Version		= testCase.Version
	testCaseResults.LineNumber	= testCase.LineNumber
	testCaseResults.SourceFile	= testCase.SourceFile
	testCaseResults.Status		= "Pending"
	testCaseResults.StartTime	= now
	testCaseResults.EndTime		= now

	return testCaseResults
end

--- Adds a failure to the Failures and Failures[ state ] arrays.
-- Will mark the results as failed.
-- @param state The state during which the failure occurred.
-- @param failure The failure.
function Chronos.TestCaseResults:AddFailure( state, failure )
	self.Steps:Add( state, failure )
	if not self.Failed then
		self.Status = "Failed"
	end
end

--- Adds an action to the Actions and Actions[ state ] arrays.
-- Will mark the results as passed if they would otherwise remain pending.
-- @param state The state during which the action occurred.
-- @param action The action.
function Chronos.TestCaseResults:AddAction( state, action )
	self.Steps:Add( state, action )
	if self.Pending then
		self.Status = "Passed"
	end
end

function Chronos.TestCaseResults:__newindex( key, val )
	if key == "Passed" or key == "Pending" or key == "Failed" then
		error( "Trying to write '" .. key .. "' to TestCaseResults. TestCaseResults only allows read-only access to '".. key .. "'." )
	else
		-- Set the values as normal.
		rawset( self, key, val )
	end
end

function Chronos.TestCaseResults:__index( key, val )
	if rawget( Chronos.TestCaseResults, key ) then
		return rawget( Chronos.TestCaseResults, key )
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

