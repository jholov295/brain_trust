--- [Internal] TestRunRecorder is responsible for recording events of a Chronos.Run() call.
module( "Chronos.TestRunRecorder", package.seeall )

---
-- @name Chronos.TestRunRecorder
-- @class table
-- @field Results An instance of Chronos.TestRunResults that the recorder controls.
Chronos.TestRunRecorder.__index = Chronos.TestRunRecorder

--- Creates a new Chronos.TestRunRecorder.
-- @return A new Chronos.TestRunRecorder.
function new( saveResults )
	local recorder = {
		Results = Chronos.TestRunResults.new( saveResults ),
		SaveResults = saveResults
	}
	setmetatable( recorder, Chronos.TestRunRecorder )
	return recorder
end

--- Marks the start of a Chronos.TestSuite's execution.
-- Triggers TestSuiteStarted on Chronos.CurrentInfoPrinter.
-- @param testSuite The Chronos.TestSuite that is about to start.
-- @return A new Chronos.TestSuiteRecorder for the test suite, associated with self.
function Chronos.TestRunRecorder:StartSuite( testSuite )
	local infoPrinter = Chronos.CurrentInfoPrinter
	if infoPrinter then
		infoPrinter:TestSuiteStarted( testSuite )
	end
	local testSuiteRecorder = Chronos.TestSuiteRecorder.new( testSuite, self, self.SaveResults )
	
	return testSuiteRecorder
end

function Chronos.TestRunRecorder:SaveSuite( testSuiteResults )
	local infoPrinter = Chronos.CurrentInfoPrinter
	if infoPrinter and self.SaveResults then
		infoPrinter:TestSuiteSaved()
	end
	self.Results.TestSuites:Add( testSuiteResults )
end

--- Marks the start of Chronos.Run()'s execution.
-- Triggers TestRunStarted on Chronos.CurrentInfoPrinter.
-- @param testSuites The Chronos.TestSuites that will be run.
function Chronos.TestRunRecorder:StartRun( testSuites, testCases )
	local infoPrinter = Chronos.CurrentInfoPrinter
	if infoPrinter then
		infoPrinter:TestRunStarted( testSuites, testCases )
	end
	self.Results.StartTime = Chronos.Time.Now()
end

--- Marks the end of Chronos.Run()'s execution.
-- Triggers TestRunEnded on Chronos.CurrentInfoPrinter.
-- @return The finished results of the test run.
function Chronos.TestRunRecorder:EndRun()
	self.Results.EndTime = Chronos.Time.Now()
	local infoPrinter = Chronos.CurrentInfoPrinter
	if infoPrinter then
		infoPrinter:TestRunEnded( self.Results )
	end
	return self.Results
end

--- Called from actions that bubble up from a Chronos.TestSuite.
-- Will mark the results as passed if they would remain pending.
-- @param action The action.
function Chronos.TestRunRecorder:SuiteAction( action )
	if self.Results.Pending then
		self.Results.Status = "Passed"
	end
end

--- Called from failures that bubble up from a Chronos.TestSuite.
-- Will mark the results as failed.
-- @param failure The failure.
function Chronos.TestRunRecorder:SuiteFailure( failure )
	if not self.Results.Failed then
		self.Results.Status = "Failed"
	end
end

