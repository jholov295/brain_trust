--- Represents an action taken during test execution. Contains a message and expected/actual values.
module( "Chronos.Action", package.seeall )

---
-- @name Action
-- @class table
-- @field Message The action message.
-- @field Expected The expected value.
-- @field Actual The actual value.
Chronos.Action.__index = Chronos.Action
Chronos.Action.Type = "Action"

--- Creates a new Chronos.Action.
-- @param message The action message.
-- @param options A table of expected and actual values. { Expected = value, Actual = value }
-- @return A new Chronos.Action.
function Chronos.Action.new( message, options )
	message = message or ""
	options = options or { }
	local action = {
		Message = message,
		Expected = ToString( options.Expected ),
		Actual = ToString( options.Actual )
	}
	setmetatable( action, Chronos.Action )
	return action
end

function Chronos.Action:__tostring()
	return self.Message
end

function Chronos.Action:__concat( other )
	return tostring( self ) .. tostring( other )
end
