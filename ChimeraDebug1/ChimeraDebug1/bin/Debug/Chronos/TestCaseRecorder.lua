--- [Internal] TestCaseRecorder is responsible for recording events of a Chronos.TestCase's execution to an instance of Chronos.TestCaseResults.
-- Actions and failures bubble up from Chronos.TestCaseRecorder, to inform the status of Chronos.TestSuiteRecorders and Chronos.TestRunRecorders.
module( "Chronos.TestCaseRecorder", package.seeall )

---
-- @name Chronos.TestCaseRecorder
-- @class table
-- @field Results An instance of Chronos.TestCaseResults that the recorder controls.
-- @field State The current state of test case execution.
-- @field TestSuiteRecorder A backreference to the Chronos.TestSuiteRecorder that created this object.
Chronos.TestCaseRecorder.__index = Chronos.TestCaseRecorder

--- Creates a new Chronos.TestCaseRecorder.
-- @param testCase The test case subject
-- @param testSuiteRecorder The Chronos.TestSuiteRecorder creating this object.
-- @return A new Chronos.TestCaseRecorder
function new( testCase, testSuiteRecorder, saveResults )
	local recorder = {
		Results = Chronos.TestCaseResults.new( testCase, saveResults ),
		State = "Idle",
		TestSuiteRecorder = testSuiteRecorder
	}
	setmetatable( recorder, Chronos.TestCaseRecorder )
	Chronos.ActiveTestCaseRecorder = recorder
	return recorder
end

--- Adds a failure to the results of the test case.
-- This call will bubble up to self.TestSuiteRecorder:CaseFailure().
-- @param failure The failure.
function Chronos.TestCaseRecorder:AddFailure( failure )
	self.Results:AddFailure( self.State, failure )
	self.TestSuiteRecorder:CaseFailure( failure )
end

--- Adds an action to the results of the test case.
-- This call will bubble up to self.TestSuiteRecorder:CaseAction().
-- @param action The action.
function Chronos.TestCaseRecorder:AddAction( action )
	self.Results:AddAction( self.State, action )
	self.TestSuiteRecorder:CaseAction( action )
end

--- Marks the end of recording.
-- Sets EndTime on the results, resets Chronos.ActiveTestCaseRecorder, and triggers TestCaseEnded on Chronos.CurrentInfoPrinter.
-- @return The finished results of the test case.
function Chronos.TestCaseRecorder:EndCase()
	self.Results.EndTime = Chronos.Time.Now()
	Chronos.ActiveTestCaseRecorder = nil
	local infoPrinter = Chronos.CurrentInfoPrinter
	if infoPrinter then
		infoPrinter:TestCaseEnded( self.Results )
	end
	return self.Results
end

--- Sets the recording state.
-- @param state The new state as a string.
function Chronos.TestCaseRecorder:SetState( state )
	self.State = state
end

--- Resets the recording state to the default. ("Idle")
function Chronos.TestCaseRecorder:ResetState()
	self.State = "Idle"
end
