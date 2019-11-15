--- Functions that require input in order for the test to continue.
module( "Chronos.Actions.Interactive", package.seeall )

--- Pauses execution and asks for input from the command line, returning the entered string.
-- <b>This function is exported into the global table.</b>
-- @param message The message to display.
-- @return The response string.
function PromptForInput( message )
	local response = Utils.Prompt( message )
	Chronos.Actions.AddAction( string.format( "%s = PromptForInput( message = %q )", ToString( response ), message ) )

	return response
end

GlobalExport( "PromptForInput" )
