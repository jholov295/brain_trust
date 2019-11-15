--- [Internal] TestSuiteRecorder is responsible for recording events of a Chronos.TestSuite's execution to an instance of Chronos.TestSuiteResults.
-- Actions and failures bubble up from Chronos.TestSuiteRecorder, to inform the status of Chronos.TestRunRecorders.
module( "Chronos.TestSuiteRecorder", package.seeall )

---
-- @name Chronos.TestSuiteRecorder
-- @class table
-- @field Results An instance of Chronos.TestSuiteResults that the recorder controls.
-- @field State The current state of test suite execution.
-- @field TestRunRecorder A backreference to the Chronos.TestRunRecorder that created this object.
Chronos.TestSuiteRecorder.__index = Chronos.TestSuiteRecorder

--- Creates a new Chronos.TestSuiteRecorder.
-- @param testSuite The test suite subject.
-- @param testRunRecorder The Chronos.TestRunRecorder creating this object.
-- @return A new Chronos.TestSuiteRecorder.
function new( testSuite, testRunRecorder, saveResults )
	local recorder = {
		Results = Chronos.TestSuiteResults.new( testSuite, saveResults ),
		State = "Idle",
		TestRunRecorder = testRunRecorder,
		SaveResults = saveResults
	}
	setmetatable( recorder, Chronos.TestSuiteRecorder )
	Chronos.ActiveTestSuiteRecorder = recorder
	return recorder
end

--- Marks the start of a Chronos.TestCase's execution.
-- Triggers TestCaseStarted on Chronos.CurrentInfoPrinter.
-- @param testCase The Chronos.TestCase about to start.
-- @return A new Chronos.TestCaseRecorder for the test case, associated with self.
function Chronos.TestSuiteRecorder:StartCase( testCase )
	local infoPrinter = Chronos.CurrentInfoPrinter
	if infoPrinter then
		infoPrinter:TestCaseStarted( testCase )
	end
	local testCaseRecorder = Chronos.TestCaseRecorder.new( testCase, self, self.SaveResults )

	return testCaseRecorder
end

--- Saves the results from a Chronos.TestCase's execution.
-- @param testCaseResults The Chronos.TestCaseResults to save.
function Chronos.TestSuiteRecorder:SaveCase( testCaseResults )
	self.Results.TestCases:Add( testCaseResults )
end

--- Marks the end of recording.
-- Sets EndTime on the results, resets Chronos.ActiveTestCaseRecorder, and triggers TestSuiteEnded on Chronos.CurrentInfoPrinter.
-- @return The finished results of the test suite.
function Chronos.TestSuiteRecorder:EndSuite()
	self.Results.EndTime = Chronos.Time.Now()
	Chronos.ActiveTestSuiteRecorder = nil
	local infoPrinter = Chronos.CurrentInfoPrinter
	if infoPrinter then
		infoPrinter:TestSuiteEnded( self.Results )
	end
	return self.Results
end

--- Sets the recording state.
-- @param state The new state as a string.
function Chronos.TestSuiteRecorder:SetState( state )
	self.State = state
end

--- Resets the recording state to the default. ("Idle")
function Chronos.TestSuiteRecorder:ResetState()
	self.State = "Idle"
end

--- Adds a failure to the results of the test suite.
-- This call will bubble up to self.TestRunRecorder:SuiteFailure().
-- @param failure The failure.
function Chronos.TestSuiteRecorder:AddFailure( failure )
	self.Results:AddFailure( self.State, failure )
	self.TestRunRecorder:SuiteFailure( failure )
end

--- Adds an action to the results of the test suite.
-- This call will bubble up to self.TestRunRecorder:SuiteAction().
-- @param action The action.
function Chronos.TestSuiteRecorder:AddAction( action )
	self.Results:AddAction( self.State, action )
	self.TestRunRecorder:SuiteAction( action )
end

--- Called from actions that bubble up from a Chronos.TestCase.
-- Will mark the results as passed if they would remain pending.
-- @param action The action.
function Chronos.TestSuiteRecorder:CaseAction( action )
	if self.Results.Pending then
		self.Results.Status = "Passed"
	end
	self.TestRunRecorder:SuiteAction( action )
end

--- Called from failures that bubble up from a Chronos.TestCase.
-- Will mark the results as failed.
-- @param failure The failure.
function Chronos.TestSuiteRecorder:CaseFailure( failure )
	if not self.Results.Failed then
		self.Results.Status = "Failed"
	end
	self.TestRunRecorder:SuiteFailure( failure )
end
