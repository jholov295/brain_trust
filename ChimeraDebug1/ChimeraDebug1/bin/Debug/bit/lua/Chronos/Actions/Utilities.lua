--- Miscellaneous functions.
module( "Chronos.Actions.Utilities", package.seeall )

--- Adds an action to the test case without changing its status.
-- Useful for recording test steps without interfering with the results.
-- <b>This function is exported into the global table.</b>
-- @param message The message to record.
function AddComment( message )
	local recorder = Chronos.GetActiveRecorder()
	if recorder then
		local results = recorder.Results
		local status = results.Status
		Chronos.Actions.AddAction( message )
		results.Status = status
	end
end

--- Delays the test for a specified number of milliseconds.
-- <b>This function is exported into the global table.</b>
-- @param milliseconds The number of milliseconds to suspend execution.
function Delay( milliseconds )
	Chronos.Actions.AddAction( "Delay " .. milliseconds .. "ms" )

	Sleep( milliseconds )
end

--- Marks the current test case as Pending, if it would otherwise pass.
-- This function will not change the status of a failed test case.
-- <b>This function is exported into the global table.</b>
function Pending()
	local recorder = Chronos.GetActiveRecorder()
	if recorder then
		if recorder.Results.Passed then
			recorder.Results.Status = "Pending"
		end
	end
end

GlobalExport( "AddComment", "Delay", "Pending" )
