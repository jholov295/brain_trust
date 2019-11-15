--- Functions for validating conditions during test execution.
module( "Chronos.Actions.Checks", package.seeall )

--- Checks that a condition is true, failing the test case if it is false.
-- <b>This function is exported into the global table.</b>
-- @param condition The condition to check.
-- @param message A message to display if the check fails. (Optional)
function Check( condition, message )
end

MakeCheck "Check"
{
	Args = { "condition" },
	Types = { condition = "boolean" },
	Expected = true,
	Actual = "$( condition )",
	PassIf = function( args )
		return args.condition
	end
}

--- Checks that a given bitwise mask of two values match.
-- <b>This function is exported into the global table.</b>
-- @param mask The bitwise mask to use.
-- @param expected The expected value.
-- @param actual The actual value.
-- @param message A message to display if the check fails. (Optional)
function CheckBits( mask, expected, actual, message )
end

MakeCheck "CheckBits"
{
	Formatter = Chronos.ToHexString,
	Args = { "mask", "expected", "actual" },
	Types = { mask = "number", expected = "number", actual = "number" },
	PseudoArgs =
	{
		expectedMask = function( args ) return bit.band( args.mask, args.expected ) end,
		actualMask = function( args ) return bit.band( args.mask, args.actual ) end
	},
	Expected = "$( expectedMask )",
	Actual = "$( actualMask )",
	FailureMessage = "Using mask $( mask ), expected $( expectedMask ) but was $( actualMask )",
	PassIf = function( args )
		return args.expectedMask == args.actualMask
	end
}

--- Checks that a given bitwise mask of a value will yield all positive bits.
-- <b>This function is exported into the global table.</b>
-- @param mask The bitwise mask to use.
-- @param actual The actual value.
-- @param message A message to display if the check fails. (Optional)
function CheckBitsHigh( mask, actual, message )
end

MakeCheck "CheckBitsHigh"
{
	Formatter = Chronos.ToHexString,
	Args = { "mask", "actual" },
	PseudoArgs =
	{
		actualMask = function( args )
			return bit.band( args.mask, args.actual )
		end
	},
	Actual = "$( actualMask )",
	Expected = "$( mask )",
	FailureMessage = "Using mask $( mask ), expected $( mask ) but was $( actualMask )",
	PassIf = function( args )
		return args.mask == args.actualMask
	end
}

--- Checks that a given bitwise mask of a value will yield all zero bits.
-- <b>This function is exported into the global table.</b>
-- @param mask The bitwise mask to use.
-- @param actual The actual value.
-- @param message A message to display if the check fails. (Optional)
function CheckBitsLow( mask, actual, message )
end

MakeCheck "CheckBitsLow"
{
	Formatter = Chronos.ToHexString,
	Args = { "mask", "actual" },
	Types = { mask = "number", actual = "number" },
	PseudoArgs =
	{
		actualMask = function( args )
			return bit.band( args.mask, args.actual )
		end,
		zero = function( args )
			return 0
		end
	},
	Actual = "$( actualMask )",
	Expected = "$( zero )",
	FailureMessage = "Using mask $( mask ), expected $( zero ) but was $( actualMask )",
	PassIf = function( args )
		return 0 == args.actualMask
	end
}

--- Checks that two objects are equal, failing the test case if they aren't.
-- This function compares table indices, checking if two tables are logically equal.
-- <b>This function is exported into the global table.</b>
-- @param expected The expected object.
-- @param actual The actual object.
-- @param message A message to display if the check fails. (Optional)
function CheckEqual( expected, actual, message )
end

--- Checks that two objects are equal, failing the test case if they aren't.
-- This function compares table indices, checking if two tables are logically equal.
-- Shows values in hex.
-- <b>This function is exported into the global table.</b>
-- @param expected The expected object.
-- @param actual The actual object.
-- @param message A message to display if the check fails. (Optional)
function CheckEqualHex( expected, actual, message )
end

MakeCheck "CheckEqual"
{
	Formatter = { Chronos.ToString, Hex = Chronos.ToHexString },
	Args = { "expected", "actual" },
	PseudoArgs =
	{
		expectedType = function( args )
			local t = type( args.expected )
			if t == "nil" then
				return ""
			end
			return t .. " "
		end,
		actualType = function( args )
			local t = type( args.actual )
			if t == "nil" then
				return ""
			end
			return t .. " "
		end
	},
	FailureMessage = "Expected $( expectedType )$( expected ) but was $( actualType )$( actual )",
	PassIf = function( args )
		if type( args.expected ) == "table" and type( args.actual ) == "table" then
			return coroutine.create( function()
				local function checkEqual( expected, actual, index )
					index = index or ""
					if type( expected ) == "table" and type( actual ) == "table" then
						for k, v in pairs( expected ) do
							local expected, actual, index = expected[ k ], actual[ k ], index .. "[" .. k .. "]"
							if type( expected ) == "table" and type( actual ) == "table" then
								checkEqual( expected, actual, index )
							elseif expected ~= actual then
								coroutine.yield
								{
									"Expected $( index ) to be $( expectedType )$( expected ) but was $( actualType )$( actual )",
									index = index,
									expected = expected,
									actual = actual
								}
							end
						end
					elseif expected ~= actual then
						coroutine.yield
						{
							"Expected $( index ) to be $( expectedType )$( expected ) but was $( actualType )$( actual )",
							index = index,
							expected = expected,
							actual = actual
						}
					end
				end
				checkEqual( args.expected, args.actual )
			end )
		else
			return args.expected == args.actual
		end
	end
}

--- Checks that a string matches the supplied match string.
-- <b>This function is exported into the global table.</b>
-- @param expected The pattern to match.
-- @param actual The string to verify.
-- @param message A message to display if the check fails. (Optional)
function CheckMatch( expected, actual, message )
end

MakeCheck "CheckMatch"
{
	Args = { "expected", "actual" },
	Types = { expected = "string", actual = "string" },
	PassIf = function( args )
		return string.match( args.actual, args.expected ) ~= nil
	end,
	FailureMessage = "Expected $( actual ) to match pattern $( expected )"
}

--- Checks that a value is no more than a given maximum.
-- <b>This function is exported into the global table.</b>
-- @param max The maximum value.
-- @param actual The value to check.
-- @param message A message to display if the check fails. (Optional)
function CheckMax( max, actual, message )
end

--- Checks that a value is no more than a given maximum.
-- <b>This function is exported into the global table.</b>
-- @param max The maximum value.
-- @param actual The value to check.
-- @param message A message to display if the check fails. (Optional)
function CheckMaxHex( max, actual, message )
end

MakeCheck "CheckMax"
{
	Formatter = { Chronos.ToString, Hex = Chronos.ToHexString },
	Args = { "max", "actual" },
	Types = { max = "number", actual = "number" },
	Expected = "<= $( max )",
	FailureMessage = "Expected at most $( max ) but was $( actual )",
	PassIf = function( args )
		return args.actual <= args.max
	end
}

--- Checks that a value is at least a given minimum.
-- <b>This function is exported into the global table.</b>
-- @param min The minimum value.
-- @param actual The value to check.
-- @param message A message to display if the check fails. (Optional)
function CheckMin( min, actual, message )
end

--- Checks that a value is at least a given minimum.
-- <b>This function is exported into the global table.</b>
-- @param min The minimum value.
-- @param actual The value to check.
-- @param message A message to display if the check fails. (Optional)
function CheckMinHex( min, actual, message )
end

MakeCheck "CheckMin"
{
	Formatter = { Chronos.ToString, Hex = Chronos.ToHexString },
	Args = { "min", "actual" },
	Types = { min = "number", actual = "number" },
	Expected = ">= $( min )",
	FailureMessage = "Expected at least $( min ) but was $( actual )",
	PassIf = function( args )
		return args.actual >= args.min
	end
}

--- Checks that two objects are not equal, failing if they are in fact equal.
-- This function compares table indices, checking if two tables are logically unequal.
-- <b>This function is exported into the global table.</b>
-- @param notExpected The unexpected object.
-- @param actual The actual object.
-- @param message A message to display if the check fails. (Optional)
function CheckNotEqual( notExpected, actual, message )
end

--- Checks that two objects are not equal, failing if they are in fact equal.
-- This function compares table indices, checking if two tables are logically unequal.
-- Shows values in hex.
-- <b>This function is exported into the global table.</b>
-- @param notExpected The unexpected object.
-- @param actual The actual object.
-- @param message A message to display if the check fails. (Optional)
function CheckNotEqualHex( notExpected, actual, message )
end

MakeCheck "CheckNotEqual"
{
	Formatter = { Chronos.ToString, Hex = Chronos.ToHexString },
	Args = { "notExpected", "actual" },
	PseudoArgs =
	{
		notExpectedType = function( args )
			local t = type( args.notExpected )
			if t == "nil" then
				return ""
			end
			return t .. " "
		end,
		actualType = function( args )
			local t = type( args.actual )
			if t == "nil" then
				return ""
			end
			return t .. " "
		end
	},
	FailureMessage = "Did not expect $( notExpectedType )$( notExpected ) but was $( actualType)$( actual )",
	Expected = "Not $( notExpected )",
	PassIf = function( args )
		local function notEqual( notExpected, actual )
			if type( notExpected ) == "table" then
				for k, v in pairs( notExpected ) do
					if notEqual( v, actual[ k ] ) then
						return true
					end
				end
			else
				if notExpected ~= actual then
					return true
				end
			end
			return false
		end
		return notEqual( args.notExpected, args.actual )
	end
}

--- Checks that a given value or sequence does not exist as a subset of a given array.
-- <b>This function is exported into the global table.</b>
-- @param notExpected The unexpected value or sequence.
-- @param array The (non-)containing array.
-- @param message A message to display if the check fails. (Optional)
function CheckNotSequence( notExpected, array, message )
end

--- Checks that a given value or sequence does not exist as a subset of a given array.
-- Shows values in hex.
-- <b>This function is exported into the global table.</b>
-- @param notExpected The unexpected value or sequence.
-- @param array The (non-)containing array.
-- @param message A message to display if the check fails. (Optional)
function CheckNotSequenceHex( notExpected, array, message )
end

MakeCheck "CheckNotSequence"
{
	Formatter = { Chronos.ToString, Hex = Chronos.ToHexString },
	Args = { "notExpected", "array" },
	Types = { array = "table" },
	Expected = "Not $( notExpected )",
	Actual = "$( array )",
	FailureMessage = "Did not expect to find $( notExpected ) in $( array )",
	PassIf = function( args )
		local notExpectedSequence = args.notExpected
		if type( notExpectedSequence ) ~= "table" then
			notExpectedSequence = { notExpectedSequence }
		end
		local f, t, i = ipairs( notExpectedSequence )
		local i, currentValueToFind = f( t, i )
		for _, foundValue in ipairs( args.array ) do
			if currentValueToFind == foundValue then
				i, currentValueToFind = f( t, i )
				if i == nil then
					break
				end
			end
		end
		return i ~= nil
	end
}

--- Checks that a value falls within a given range.
-- <b>This function is exported into the global table.</b>
-- @param min The minimum value.
-- @param max The maximum value.
-- @param actual The value to check.
-- @param message A message to display if the check fails. (Optional)
function CheckRange( min, max, actual, message )
end

--- Checks that a value falls within a given range.
-- <b>This function is exported into the global table.</b>
-- @param min The minimum value.
-- @param max The maximum value.
-- @param actual The value to check.
-- @param message A message to display if the check fails. (Optional)
function CheckRangeHex( min, max, actual, message )
end

MakeCheck "CheckRange"
{
	Formatter = { Chronos.ToString, Hex = Chronos.ToHexString },
	Args = { "min", "max", "actual" },
	Types = { min = "number", max = "number", actual = "number" },
	Expected = ">= $( min ) and <= $( max )",
	FailureMessage = "Expected at least $( min ) and at most $( max ) but was $( actual )",
	PassIf = function( args )
		return args.actual >= args.min and args.actual <= args.max
	end
}

--- Checks that a given value or sequence exists as a subset of a given array.
-- <b>This function is exported into the global table.</b>
-- @param expected The expected value or sequence.
-- @param array The containing array.
-- @param message A message to display if the check fails. (Optional)
function CheckSequence( expected, array, message )
end

--- Checks that a given value or sequence exists as a subset of a given array.
-- Shows values in hex.
-- <b>This function is exported into the global table.</b>
-- @param expected The expected value or sequence.
-- @param array The containing array.
-- @param message A message to display if the check fails. (Optional)
function CheckSequenceHex( expected, array, message )
end

MakeCheck "CheckSequence"
{
	Formatter = { Chronos.ToString, Hex = Chronos.ToHexString },
	Args = { "expected", "array" },
	Actual = "$( array )",
	FailureMessage = "Expected to find $( expected ) in $( array )",
	PassIf = function( args )
		local expectedSequence = args.expected
		if type( expectedSequence ) ~= "table" then
			expectedSequence = { expectedSequence }
		end
		local f, t, i = ipairs( expectedSequence )
		local i, currentValueToFind = f( t, i )
		for _, foundValue in ipairs( args.array ) do
			if currentValueToFind == foundValue then
				i, currentValueToFind = f( t, i )
				if i == nil then
					break
				end
			end
		end
		return i == nil
	end
}

--- Checks that a function takes at most max milliseconds to run.
-- <b>This function is exported into the global table.</b>
-- @param max The maximum run time in milliseconds.
-- @param func The function to time.
-- @param message A message to display if the check fails. (Optional)
function CheckTimeMax( max, func, message )
end

MakeCheck "CheckTimeMax"
{
	Args = { "max", "func" },
	Types = { max = "number", func = "function" },
	PseudoArgs =
	{
		actual = function( args )
			local startTime = Chronos.Time.Now()
			args.func()
			local endTime = Chronos.Time.Now()
			return endTime - startTime
		end
	},
	FailureMessage = "Expected function to take at most $( max )ms but took $( actual )ms",
	Expected = "<= $( max )ms",
	Actual = "$( actual )ms",
	PassIf = function( args )
		return args.actual <= args.max
	end
}

--- Checks that a function takes at least min milliseconds to run.
-- <b>This function is exported into the global table.</b>
-- @param min The minimum run time in milliseconds.
-- @param func The function to time.
-- @param message A message to display if the check fails. (Optional)
function CheckTimeMin( min, func, message )
end

MakeCheck "CheckTimeMin"
{
	Args = { "min", "func" },
	Types = { min = "number", func = "function" },
	PseudoArgs =
	{
		actual = function( args )
			local startTime = Chronos.Time.Now()
			args.func()
			local endTime = Chronos.Time.Now()
			return endTime - startTime
		end
	},
	FailureMessage = "Expected function to take at least $( min )ms but took $( actual )ms",
	Expected = ">= $( min )ms",
	Actual = "$( actual )ms",
	PassIf = function( args )
		return args.actual >= args.min
	end
}

--- Checks that a function takes at least min milliseconds and at most max milliseconds to run.
-- <b>This function is exported into the global table.</b>
-- @param min The minimum run time in milliseconds.
-- @param max The maximum run time in milliseconds.
-- @param func The function to time.
-- @param message A message to display if the check fails. (Optional)
function CheckTimeRange( min, max, func, message )
end

MakeCheck "CheckTimeRange"
{
	Args = { "min", "max", "func" },
	Types = { min = "number", max = "number", func = "function" },
	PseudoArgs =
	{
		actual = function( args )
			local startTime = Chronos.Time.Now()
			args.func()
			local endTime = Chronos.Time.Now()
			return endTime - startTime
		end
	},
	FailureMessage = "Expected function to take between $( min )ms and $( max )ms but took $( actual )ms",
	Expected = ">= $( min )ms and <= $( max )ms",
	Actual = "$( actual )ms",
	PassIf = function( args )
		return args.actual >= args.min and args.actual <= args.max
	end
}


