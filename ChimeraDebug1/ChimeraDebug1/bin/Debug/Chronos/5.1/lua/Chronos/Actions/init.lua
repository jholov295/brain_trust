--- Actions and failures are recorded for each test case and test suite as you run checks. These functions allow you to programmatically add your own actions and failures.
-- <pre class="example">
-- TestCase "My Test Case"<br/>
-- {<br/>
-- &nbsp; function()<br/>
-- &nbsp; &nbsp; AddAction( "Running important code" )<br/>
-- &nbsp; &nbsp; if not ImportantCode() then<br/>
-- &nbsp; &nbsp; &nbsp; AddFailure( "Important code failed" )<br/>
-- &nbsp; &nbsp; end<br/>
-- &nbsp; end<br/>
-- }<br/>
-- </pre>
module( "Chronos.Actions", package.seeall )

--- Adds an action message to the recorded actions of the current test scope.
-- <b>This function is exported into the global table.</b>
-- @param message The message to record.
-- @param options Additional options. (Optional) { Expected = value, Actual = value }
-- @return A fully-formed Action, if there was an active recorder.
function AddAction( message, options )
	recorder = Chronos.GetActiveRecorder()
	if recorder then
		local action = Chronos.Action.new( message, options )
		recorder:AddAction( action )
		return action
	end
end

--- Adds a failure message to the recorded failures of the current test scope.
-- <b>This function is exported into the global table.</b>
-- @param message The message to record.
-- @param level The error level of the failure. (Optional) See <a href="http://www.lua.org/manual/5.1/manual.html#pdf-error">Lua error()</a>
-- @return A fully-formed Failure, if there was an active recorder.
function AddFailure( message, level )
	local recorder = Chronos.GetActiveRecorder()
	if recorder then
		if tonumber( level ) then
			level = level + 1
		else
			level = nil
		end
		local failure = Chronos.Failure.new( message, level )
		recorder:AddFailure( failure )
		return failure
	end
end

GlobalExport( "AddAction", "AddFailure" )

require "Chronos.Actions.MakeCheck"
require "Chronos.Actions.Checks"
require "Chronos.Actions.Interactive"
require "Chronos.Actions.Traceability"
require "Chronos.Actions.Utilities"
