--- Provides a formatting function for displaying time in reports.
module( "Chronos.Time", package.seeall )

local socket = require "socket"

function Now()
	return socket.gettime() * 1000
end

local function timeFormatTwoChar( s )
	s = "" .. s
	while s:len() < 2 do
		s = "0" .. s
	end
	return s
end

local function timeFormatMilliseconds( ms )
	ms = "" .. ms
	while ms:len() < 3 do
		ms = "0" .. ms
	end
	return ms
end

--- Formats a given timeframe so that only necessary time components are shown. (eg. "1:01.53", not "00:01:01.530000")
-- @param milliseconds The timeframe in milliseconds.
-- @return The formatted time as a string.
function Format( milliseconds )
	local hours = math.floor( milliseconds / ( 60 * 60 * 1000 ) )
	local minutes = math.floor( milliseconds / ( 60 * 1000 ) % 60 )
	local seconds = math.floor( milliseconds / ( 1000 ) % 60 )
	local ms = math.floor( milliseconds % 1000 )
	local s = ""
	if hours > 0 then
		s = s .. hours .. ":"
		s = s .. timeFormatTwoChar( minutes ) .. ":"
		s = s .. timeFormatTwoChar( seconds )
	elseif minutes > 0 then
		s = s .. minutes .. ":"
		s = s .. timeFormatTwoChar( seconds )
	else
		s = s .. seconds
	end
	if ms > 0 then
		s = s .. "." .. timeFormatMilliseconds( ms )
	end
	if hours == 0 and minutes == 0 then
		s = s .. "s"
	end
	return s
end
