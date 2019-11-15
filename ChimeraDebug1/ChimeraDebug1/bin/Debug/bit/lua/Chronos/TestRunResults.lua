--- Contains information about a test run.
module( "Chronos.TestRunResults", package.seeall )

---
-- @name TestRunResults
-- @class table
-- @field StartTime The start time of the test run.
-- @field EndTime The end time of the test run.
-- @field Time The total time of the test run.
-- @field Status "Passed" "Pending" or "Failed"
-- @field Passed True if the test run passed.
-- @field Pending True if the test run is pending.
-- @field Failed True if the test run failed.
-- @field TestSuites An array of Chronos.TestSuiteResults. (Also indexed by name: TestSuites["My Test Suite"])
-- @field TestSuites.Passed An array of Chronos.TestSuiteResults whose status is Passed.
-- @field TestSuites.Pending An array of Chronos.TestSuiteResults whose status is Pending.
-- @field TestSuites.Failed An array of Chronos.TestSuiteResults whose status is Failed.
-- @field TestCases An array of Chronos.TestCaseResults. (Also indexed by name: TestCases["My Test Case"])
-- @field TestCases.Passed An array of Chronos.TestCaseResults whose status is Passed.
-- @field TestCases.Pending An array of Chronos.TestCaseResults whose status is Pending.
-- @field TestCases.Failed An array of Chronos.TestCaseResults whose status is Failed.

--- Creates a new Chronos.TestRunResults.
-- @return A new Chronos.TestRunResults.
function Chronos.TestRunResults.new( saveResults )
	local now = Chronos.Time.Now()
	local path = "TestRun-" .. now
	if CHRONOS_TEST_MODE then
		path = nil
	end

	local testRunResults = setmetatable( { }, Chronos.TestRunResults )
	if saveResults then
		testRunResults = Chronos.FileTable.new( path, "Chronos.TestRunResults" )
	end

	testRunResults.TestSuites = Chronos.TestSuiteCollection.new()
	testRunResults.Status = "Pending"
	testRunResults.StartTime = now
	testRunResults.EndTime = now
	testRunResults.OSTime = os.time()

	return testRunResults
end

function Chronos.TestRunResults:__newindex( key, val )
	if key == "Passed" or key == "Pending" or key == "Failed" then
		error( "Trying to write '" .. key .. "' to TestRunResults. TestRunResults only allows read-only access to '".. key .. "'." )
	else
		-- Set the values as normal.
		rawset( self, key, val )
	end
end

function Chronos.TestRunResults:__index( key, val )
	if key == "Passed" or key == "Pending" or key == "Failed" then
		return self.Status == key
	end

	if key == "TestCases" then
		local testCases = Chronos.TestCaseCollection.new()
		for _, ts in ipairs( self.TestSuites ) do
			for _, tc in ipairs( ts.TestCases ) do
				testCases:Add( tc )
			end
		end
		return testCases
	end

	if key == "Time" then
		return self.EndTime - self.StartTime
	end
end

