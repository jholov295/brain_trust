---	Helper functions that can be used to help manipulate strings.
--
--	@name		cllib.String
--	@author		<a href="mailto:ryan.pusztai@gentex.com">Ryan Pusztai</a>
--	@release	1.12 <01/09/2009>
--
--	<h3>Note:</h3>
--	<ul>
--	This module is part of <em>cllib</em> (<em>Common Lua Library</em>). You will need extra
--	files to use these functions. See 'Usage:' section for more information.
--	</ul>
--
--	<h3>Usage:</h3>
--	<ul>
--	To use these scripts all you need to do is <code>require()</code> at the top of
--	the file.
--	<br />
--	This is an example of using an included module:
--		<pre class="example">require( "ModuleName" )</pre>
--	This is an example of calling a function in that module:
--		<pre class="example">ModuleName.CoolFunction( parameter1, parameter2 )</pre>
--	</ul>
module( "String", package.seeall )

-- STRINGUTILS FUNCTIONS --------------------------------------------------------
--

---	Trims white space from <em>s</em>.
--	@param s String to trim the whitespace from.
--	@return String with all the whitespace removed from the begining
--	and end of <em>s</em>.
function Trim( s )
	if type( s ) ~= "string" then
		error("Expected a string, but got a "..type( s ) )
	end
    return ( string.gsub( s, "^%s*(.-)%s*$", "%1" ) )
end

---	Formats any type into an ASCII string. Be aware that only numbers that are
--	less then 256 are allowed. This only applies to numbers, not any other data types.
--	@param val Value to be converted. It can be a table and it will build the
--		elements into a single string.
--	@param separator [OPT] String to use to denote element separation. Defaults to "".
--	@return String that is formated as ASCII.
function ToAscii( val, separator )
	separator = separator or ""
	if type( separator ) ~= "string" then
		error( "bad argument #2 to String.ToAscii' (Expected string but recieved "..type( separator )..")" )
	end

	local msgAscii = ""

	if type( val ) == "table" then
		for i, value in ipairs( val ) do
			if i ~= #val then
				msgAscii = msgAscii..ToAscii( value )..separator
			else
				msgAscii = msgAscii..ToAscii( value )
			end
		end
	elseif type( val ) == "string" then
		msgAscii = val
	elseif type( val ) == "number" then
		if val < 0 or val > 255 then
			error( "bad argument #1 to 'String.ToAscii' (Only numbers between 0 and 255 are allowed)." )
		end

		msgAscii = string.char( val )
	else
		error( "bad argument #1 to 'String.ToAscii' (Unexpected data type. Found "..type( s )..")" )
	end

	return msgAscii
end

---	Formats any value into a decimal representaion. If it is a table of values
--	each value is converted to decimal and then placed in a buffer of comma
--	separated values. e.g. "123, 456, 78, 90" Be aware that if you have signed
--	numbers it will treat every value in the table as signed.
--	@param val Value to be converted. This can be a table and then a string of
--		comma separated values will be returned.
--	@param separator [OPT] String that represents what separater to use if a
--		table is passed into the function. Defaults to ", ".
--	@param isSigned [OPT] Boolean that if true converts the number as a
--		signed value, else it treats it as an unsigned value. For a table of
--		values it will treat all of them as signed if this is true, else all
--		as unsigned.
--	@return If not a table it returns the <i>val</i> as a decimal representation.
--		If a table it returns it as a string of comma separated values that are
--		converted to decimal.
--
--	<h3>Note:</h3>
--	<ul>
--	You should use 'tonumber()' from Lua if you don't need the dynamic handling
-- 	of tables.
--	</ul>
function ToDec( val, separator, isSigned )
	if type( val ) == "table" then
		-- Setup variables.
		separator = separator or ", "
		if type( separator ) ~= "string" then
			error( "bad argument #2 to String.ToDec' (Expected string but recieved "..type( separator )..")" )
		end

		local tmp = ""
		for k, v in ipairs( val ) do
			if k == 1 then
				tmp = ToDec( v, nil, isSigned )
			else
				tmp = tmp..separator..ToDec( v, nil, isSigned )
			end
			end

		return tmp
		end

		-- Get the results also as a decimal number.
	local retVal = tonumber( val )

	-- If not properly converted treat it as binary data.
	if not retVal then
		retVal =  tonumber( ToHex( val ) )
	end

	if isSigned then
		local tmp = ToHex( val, nil, false )
		local maxVal = 2^( ( tmp:len() - 1 ) * 8 )
		local maxPosVal = ( maxVal / 2 ) - 1

		if retVal > maxPosVal then
			retVal = retVal - maxVal
		end
	end

	return retVal
end

--	Internal use only. Formats a number into a string hex representaion.
--	@param num Number to be converted.
--	@param byteSeparator [OPT] String to use to denote byte separation. Defaults to "".
--	@param prefix [OPT] String to be used as a prefix for the return value.
--		Defaults to "0x". e.g. 0xAB0438
--	@return String that is formated as hex.
local function NumberToHex( num, byteSeparator, prefix )
	if type( num ) ~= "number" then error( "bad argument #1 to String.NumberToHex' (Expected number but recieved "..type( num )..")" ) end
	local retVal = ""
	separator = byteSeparator or ""
	prefix = prefix or "0x"
	if type( separator ) ~= "string" then error( "bad argument #2 to String.NumberToHex' (Expected string but recieved "..type( separator )..")" ) end
	if type( prefix ) ~= "string" then error( "bad argument #3 to String.NumberToHex' (Expected string but recieved "..type( prefix )..")" ) end

	-- Convert the number to a hex string.
	local tmp = string.format( "%02X", num )

	-- Make it a byte string even.
	if tmp:len() % 2 ~= 0 then
		tmp = "0"..tmp
	end

	-- Add byte separators if required.
	if separator:len() > 0 then
		for i = 1, tmp:len() do
			if i % 2 == 0 then
				-- add separator only if it is between the begining and end.
				if i ~= tmp:len() then
					retVal = retVal..tmp:sub(i - 1, i)..separator
				else
					retVal = retVal..tmp:sub(i - 1, i)
				end
			end
		end
	else
		retVal = tmp
	end

	-- Add the prefix (0x) if required.
	retVal = prefix..retVal

	return retVal
end

---	Formats any type into a string hex representaion.
--	@param val Value to be converted. It can be a table and it will build the
--		elements into a single string.
--	@param separator [OPT] String to use to denote element separation. Defaults to "".
--	@param useHexPrefix [OPT] Boolean that should be true if you want the '0x'
--		to be prefixed to the returned string. Defaults to true.
--		e.g. 0xAB0438
--	@return String that is formated as hex.
function ToHex( val, separator, useHexPrefix )
	separator = separator or ""
	if type( separator ) ~= "string" then
		error( "bad argument #2 to String.ToHex' (Expected string but recieved "..type( separator )..")" )
	end
	if useHexPrefix == nil then useHexPrefix = true end
	local msgHex = ""
	if useHexPrefix then msgHex = "0x" end

	if type( val ) == "table" then
		local tmp = ""

		for i, value in ipairs( val ) do
			tmp = ToHex( value, separator, false )

			if i ~= #val then
				msgHex = msgHex..tmp..separator
			else
				msgHex = msgHex..tmp
			end
		end
	elseif type( val ) == "string" then
		local tmp = tonumber( val )

		-- Check that is was converted properly.
		if tmp then
			msgHex = NumberToHex( tmp, nil, msgHex )
		else
			-- Treat data as binary.
			-- Loop through the individual bytes of the message and format them.
			for i = 1, val:len() do
				msgHex = string.format( "%s%02X", msgHex, val:byte( i ) )
			end
		end
	elseif type( val ) == "number" then
		msgHex = NumberToHex( val, nil, msgHex )
	else
		error( "bad argument #1 to 'String.ToHex' (Unexpected data type. Found "..type( val )..")" )
	end

	return msgHex
end

---	Formats a string with C-style hex escapes (\x) for every two characters.
--	@param s String or single element table that contains the message
--		that needs to be converted.
--	@return String that is formated with C-style hex escapes (\x).
--
--	<h3>Note:</h3>
--	<ul>
--	This will truncate the last byte if it doesn't have 2 characters.
-- 	For example: String.ToEscapedHex( "7FABCDE" ) would return "\x7F\xAB\xCD"
--	Notice the missing 'E'.
--	</ul>
function ToEscapedHex( s )
	local tmp = ""

	if ( type( s ) == "table" ) then
		tmp = unpack( s )
	elseif ( type( s ) == "string" ) then
		tmp = s
	else
		error( "Expected a string or a table." )
	end

	-- Setup temp containers.
	local msgEscapedHex = ""
	-- Loop through the individual bytes of the message and format them.
	for i = 1, tmp:len() do
		if ( i % 2 == 0 ) then
			msgEscapedHex = string.format( "%s\\x%s", msgEscapedHex,
				tmp:sub( i - 1, i ) )
		end
	end

	-- Put quotes around the string to make sure that Decode()
	-- is called in DynamicInvoke.
	return string.format( "\"%s\"", msgEscapedHex )
end

---	Formats a string into ASCII, hex and decimal representaions.
--	@param msg String that contains the message that needs to be converted.
--	@return String that is formated as hex (ASCII) [decimal].
function FormatMessage( msg )
	assert( type( msg ) == "string", "Expected a string" )

	return string.format( "%s (%s) [%s]", ToHex( msg ), msg, ToDec( msg ) )
end
