--- Represents a failure during test execution. Contains a message and a stack trace.
module( "Chronos.Failure", package.seeall )

---
-- @name Failure
-- @class table
-- @field Message The failure message.
-- @field StackTrace The stack trace.
Chronos.Failure.__index = Chronos.Failure
Chronos.Failure.Type = "Failure"

--- Creates a new Chronos.Failure. If an error level is given, the failure will record the stack trace, trying to only capture user-defined functions.
-- @param message The failure message.
-- @param level The error level of the failure. See <a href="http://www.lua.org/manual/5.1/manual.html#pdf-error">Lua error()</a>
-- @return A new Chronos.Failure.
function Chronos.Failure.new( message, level )
	message = message or ""
	local failure = {
		Message = message,
		StackTrace = nil
	}
	setmetatable( failure, Chronos.Failure )
	if level then
		failure:GrabStackTrace( level + 1 )
	end
	return failure
end

function Chronos.Failure:GrabStackTrace( level )
	level = level or 1
	local stackTrace = debug.traceback( "", level + 1 )
	stackTrace = string.sub( stackTrace, 2, #stackTrace )
	local lines = { }
	for line in pl.stringx.lines( stackTrace ) do
		if string.match( line, [[Chronos.-Test.-%.lua.-in function 'TryFunction']] ) then
			lines[ #lines ] = nil
			break
		end
		table.insert( lines, line )
	end
	self.StackTrace = table.concat( lines, "\n" )
end

function Chronos.Failure:ToLongString( stackTraceIndent )
	stackTraceIndent = stackTraceIndent or 0
	local indentString = ""
	for i = 1, stackTraceIndent do
		indentString = indentString .. " "
	end
	if self.StackTrace then
		return self.Message .. "\n" .. indentString .. self.StackTrace
	end
	return self.Message
end

function Chronos.Failure:__tostring()
	return self.Message
end

function Chronos.Failure:__concat( other )
	return tostring( self ) .. tostring( other )
end
