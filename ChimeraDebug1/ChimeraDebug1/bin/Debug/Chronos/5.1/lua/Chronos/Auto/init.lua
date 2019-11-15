require "Chronos"
---	A typical usage of AutoChronos looks like this:
--
--<pre class="example">
--require "Chronos"<br/>
--require "Chronos.Auto"<br/>
--require "gScripted"<br/>
--<br/>
--local deviceComm<br/>
--<br/>
--TestSuite "Auto-Generated Test Cases"<br/>
--{<br/>
--&nbsp; 	Auto "commandsets/Audi_KWP.xml"<br/>
--&nbsp; 	{<br/>
--&nbsp; 		{ Pattern = "Coding Block .*", Reqs = { "SR-123" } },<br/>
--&nbsp; 		"ALS Return Pulse Width Values",<br/>
--&nbsp; 		{
--&nbsp; 			Name = "Aim Calibration Values",<br/>
--&nbsp; 			Params =<br/>
--&nbsp; 			{<br/>
--&nbsp; 				["First Row"] = { Valid = { 6, 10, 55 }, Invalid = { 1, 99 } },<br/>
--&nbsp; 				["First Column"] = { Valid = { 50 }, Invalid = { 107 } },<br/>
--&nbsp; 				["Retrieve_Stored_Error"] = { Valid = { 1 } }<br/>
--&nbsp; 			},<br/>
--&nbsp; 			Verify = true<br/>
--&nbsp; 		}<br/>
--<br/>
--&nbsp; 		Setup = function()<br/>
--&nbsp; 			deviceComm = DeviceComm.new( "commandsets/Audi_KWP.xml" )<br/>
--&nbsp; 		end,<br/>
--<br/>
--&nbsp; 		Test = function( command )<br/>
--&nbsp; 			local results = AutoRun( deviceComm, command )<br/>
--&nbsp; 			AutoCheck( deviceComm, results )<br/>
--&nbsp; 		end<br/>
--&nbsp; 	}<br/>
--}</pre>
--
--	<b>Important Notes</b>
--
--	<ul>
--		<li>You can pass in the regular TestCase functions, Setup, Teardown, and Test.</li>
--		<li>The Test function here is different in that it takes an argument. AutoChronos will do some preprocessing and call this function with a Command object, set up according to what configuration options were passed in.</li>
--	</ul>
module( "Chronos.Auto", package.seeall )

local ignore = function() end
local autoRun = ignore
local autoCheck = ignore

local types =
{
	U8 = { Min = 0x00, Max = 0xFF },
	U16 = { Min = 0x0000, Max = 0xFFFF },
	U32 = { Min = 0x00000000, Max = 0xFFFFFFFF },
	S8 = { Min = -0x80, Max = 0x7F },
	S16 = { Min = -0x8000, Max = 0x7FFF },
	S32 = { Min = -0x80000000, Max = 0x7FFFFFFF },
}

local dontCareTypes =
{
	string = "string",
	F32 = "number",
	D64 = "number"
}

-- This function returns true if the given value is within the possible range for the given type.
-- For example, -1 cannot be represented by a U8.
-- Arrays must have the specified length. (e.g. U8[3]) All of their values must fall within the possible range for the element type.
-- Any value is acceptable for a string, F32, or D64.
-- This will return false for unknown types.
function IsValidValueForType( value, typ )
	local function isValidValueForType( value, typ )
		local typeInfo = types[ typ ]
		if typeInfo then
			local okay = value >= typeInfo.Min and value <= typeInfo.Max
			if not okay then
				return false, "is not a representable value using data type " .. typ .. ": " .. value .. "."
			else
				return true
			end
		end
		if dontCareTypes[ typ ] then
			if dontCareTypes[ typ ] == type( value ) then
				return true
			else
				return false, "must be a " .. dontCareTypes[ typ ] .. "."
			end
		end
		return false, "is an unknown data type: " .. typ .. "."
	end
	local arrayType, arraySize = string.match( typ, "(.*)%[(.*)%]" )
	if type( value ) == "table" and arraySize == "" then
		arraySize = #value
	end
	if arrayType and arraySize then
		if type( value ) ~= "table" then
			return false, "must be a table."
		end
		for i = 1, arraySize do
			local okay, message = isValidValueForType( value[ i ], arrayType )
			if not okay then
				return false, message
			end
		end
		return true
	else
		return isValidValueForType( value, typ )
	end
end

function IsValidValueForRange( value, range )
	if type( value ) == "table" then
		for i, v in ipairs( value ) do
			if v < range.Low[ i ] or v > range.High[ i ] then
				return false
			end
		end
		return true
	else
		return value >= range.Low and value <= range.High
	end
end

function FindCallbacks( options )
	local callbacks = { }
	for _, option in ipairs( options ) do
		if type( option ) == "function" then
			callbacks.Test = option
		end
	end
	for _, name in ipairs { "Setup", "Test", "Teardown" } do
		if type( options[ name ] ) == "function" then
			if callbacks[ name ] then
				error( "Already specified a callback for " .. name )
			end
			callbacks[ name ] = options[ name ]
		end
	end
	return callbacks
end

function GenerateDescriptionsFromCommand( deviceComm, command, baseDescription )
	-- Dear reader: I know this looks scary, but trust me, it's quite straight-forward if you just read it.
	-- A better way to understand this function is to look at the tests for GenerateDescriptionsFromBlah.
	baseDescription = baseDescription or { }
	local descriptions = { }
	local modes = { }
	if command.IsDoable then
		modes.Do = "In"
	end
	if command.IsWritable then
		modes.Write = "Mem"
	end
	if command.IsReadable and ( not command.IsWritable or baseDescription.Verify == false ) then
		modes.Read = ""
	end
	for runMode, parameterMode in pairs( modes ) do
		local params = { }
		if runMode ~= "Read" then
			for k, v in pairs( command[ parameterMode ] ) do
				local valid = { }
				local invalid = { }
				local range = command:GetParameterRange( k )
				local paramType = command:GetParameterType( k )
				if IsValidValueForType( v, paramType ) then
					table.insert( valid, v )
				end
				local function isEqual( v1, v2 )
					if type( v1 ) == "table" then
						if type( v2 ) ~= "table" then
							return false
						end
						for k, v in pairs( pl.tablex.merge( v1, v2, true ) ) do
							if not isEqual( v1[ k ], v2[ k ] ) then
								return false
							end
						end
					else
						if type( v2 ) == "table" then
							return false
						end
						if v1 ~= v2 then
							return false
						end
					end
					return true
				end
				local function addValids( valids )
					for _, value in ipairs( valids ) do
						if IsValidValueForRange( value, range ) and IsValidValueForType( value, paramType ) and #pl.tablex.filter( valid, function( v ) return isEqual( v, value ) end ) == 0 then
							table.insert( valid, value )
						end
					end
				end
				local function addInvalids( invalids )
					for _, value in ipairs( invalids ) do
						if IsValidValueForType( value, paramType ) and #pl.tablex.filter( valid, function( v ) return isEqual( v, value ) end ) == 0 then
							table.insert( invalid, value )
						end
					end
				end
				if type( v ) == "number" then
					addValids
					{
						range.Low,
						range.Low + 1,
						range.High - 1,
						range.High
					}
					addInvalids
					{
						range.Low - 1,
						range.High + 1
					}
				elseif type( v ) == "table" and #pl.tablex.filter( v, function( v ) return type( v ) == "number" end ) == #v then
					addValids
					{
						range.Low,
						pl.tablex.imap( function( v ) return v + 1 end, range.Low ),
						pl.tablex.imap( function( v ) return v - 1 end, range.High ),
						range.High
					}
					addInvalids
					{
						pl.tablex.imap( function( v ) return v - 1 end, range.Low ),
						pl.tablex.imap( function( v ) return v + 1 end, range.High )
					}
				end
				params[ k ] =
				{
					Valid = valid,
					Invalid = invalid
				}
			end
		end
		local verify = false
		if runMode == "Write" and command.IsReadable and baseDescription.Verify ~= false then
			verify = true
		end
		local description =
		{
			Name = command.Name,
			Reqs = { },
			Params = params,
			Mode = runMode,
			Verify = verify
		}
		table.insert( descriptions, description )
	end
	return descriptions
end

function GenerateDescriptionsFromPattern( deviceComm, commandPattern, baseDescription )
	return GenerateDescriptionsFromNames( deviceComm, pl.tablex.filter( deviceComm:GetAllCommands(), function( n ) return string.match( n, commandPattern ) ~= nil end ), baseDescription )
end

function GenerateDescriptionsFromCommands( deviceComm, commands, baseDescription )
	local descriptions = { }
	for _, command in ipairs( commands ) do
		local generated = GenerateDescriptionsFromCommand( deviceComm, command, baseDescription )
		for _, d in ipairs( generated ) do
			table.insert( descriptions, d )
		end
	end
	return descriptions
end

function GenerateDescriptionsFromName( deviceComm, commandName, baseDescription )
	return GenerateDescriptionsFromCommand( deviceComm, deviceComm:FindCommand( commandName ), baseDescription )
end

function GenerateDescriptionsFromNames( deviceComm, commandNames, baseDescription )
	return GenerateDescriptionsFromCommands( deviceComm, pl.tablex.imap( function( c ) return deviceComm:FindCommand( c ) end, commandNames ), baseDescription )
end

local runModes =
{
	Write = "Mem",
	FailWrite = "Mem",
	Read = "Mem",
	FailRead = "Mem",
	Do = "In",
	FailDo = "In"
}

function GetParameterMode( runMode )
	return runModes[ runMode ]
end

function GenerateCasesFromDescription( deviceComm, description )
	local cases = { }
	if description.Mode == "Read" then
		local runMode = description.Mode
		local parameterMode = GetParameterMode( runMode )
		table.insert( cases, { Name = description.Name, Reqs = description.Reqs, RunMode = runMode, ParameterMode = parameterMode, Params = { }, Verify = false } )
	else
		local maxValid = 0
		for paramName, paramInfo in pairs( description.Params ) do
			maxValid = math.max( maxValid, #paramInfo.Valid )
		end
		for i = 1, maxValid do
			local params = { }
			for paramName, paramInfo in pairs( description.Params ) do
				params[ paramName ] = paramInfo.Valid[ math.min( #paramInfo.Valid, i ) ]
			end
			local runMode = description.Mode
			local parameterMode = GetParameterMode( runMode )
			table.insert( cases, { Name = description.Name, Reqs = description.Reqs, RunMode = runMode, ParameterMode = parameterMode, Params = params, Verify = description.Verify or false } )
		end
		for invalidParamName, invalidParamInfo in pairs( description.Params ) do
			for i, invalidValue in ipairs( invalidParamInfo.Invalid ) do
				local params = { }
				params[ invalidParamName ] = invalidValue
				for validParamName, validParamInfo in pairs( description.Params ) do
					if validParamName ~= invalidParamName then
						params[ validParamName ] = validParamInfo.Valid[ math.min( #validParamInfo.Valid, i ) ]
					end
				end
				local runMode = "Fail" .. description.Mode
				local parameterMode = GetParameterMode( runMode )
				table.insert( cases, { Name = description.Name, Reqs = description.Reqs, RunMode = runMode, ParameterMode = parameterMode, Params = params, Verify = false } )
			end
		end
	end
	return cases
end

function GenerateCasesFromDescriptions( deviceComm, descriptions )
	local cases = { }
	for _, description in ipairs( descriptions ) do
		local descriptionCases = GenerateCasesFromDescription( deviceComm, description )
		for _, case in ipairs( descriptionCases ) do
			table.insert( cases, case )
		end
	end
	return cases
end

function NormalizeDescription( deviceComm, description )
	if type( description ) == "string" then
		return GenerateDescriptionsFromName( deviceComm, description )
	elseif type( description ) == "function" then
		return { }
	else
		local generated
		if description.Pattern then
			generated = GenerateDescriptionsFromPattern( deviceComm, description.Pattern, description )
		else
			generated = GenerateDescriptionsFromName( deviceComm, description.Name, description )
		end
		local descriptions = { }
		for _, gen in ipairs( generated ) do
			if not description.Mode or gen.Mode == description.Mode then
				local d = pl.tablex.merge( gen, description, true )
				d.Pattern = nil
				table.insert( descriptions, d )
			end
		end
		return descriptions
	end
end

function NormalizeDescriptions( deviceComm, descriptions )
	local normalized = { }
	for _, d in ipairs( descriptions ) do
		for _, description in ipairs( NormalizeDescription( deviceComm, d ) ) do
			table.insert( normalized, description )
		end
	end
	return normalized
end

function ValidateDescription( deviceComm, description )
	local name = description.Name
	assert( type( description.Name ) == "string", "Command description Name must be a string." )
	assert( type( description.Reqs ) == "table", "Command description (" .. name .. ") Reqs must be a table." )
	assert( type( description.Verify ) == "boolean", "Command description (" .. name .. ") Verify must be a boolean." )
	assert( type( description.Params ) == "table", "Command description (" .. name .. ") Params must be a table." )
	assert( description.Mode == "Do" or description.Mode == "Write" or description.Mode == "Read", "Command description (" .. name .. ") Mode must be Do, Write, or Read." )
	local command = deviceComm:FindCommand( description.Name )
	if description.Mode == "Do" then
		assert( command.IsDoable, "Command description (" .. name .. ") using Mode = Do must be doable." )
	elseif description.Mode == "Write" then
		assert( command.IsWritable, "Command description (" .. name .. ") using Mode = Write must be writable." )
	elseif description.Mode == "Read" then
		assert( command.IsReadable, "Command description (" .. name .. ") using Mode = Read must be readable." )
	end
	if description.Verify then
		assert( description.Mode == "Write", "Command description (" .. name .. ") using Verify = true must use Mode = Write." )
		assert( command.IsWritable and command.IsReadable, "Command description (" .. name .. ") using Verify = true must be both writable and readable." )
	end
	local paramMode = GetParameterMode( description.Mode )
	for param, paramInfo in pairs( description.Params ) do
		assert( command[ paramMode ][ param ], "Command description (" .. name .. ") parameter does not exist: " .. param .. "." )
		assert( type( paramInfo ) == "table", "Command description (" .. name .. ") Params." .. param .. " must be a table." )
		assert( type( paramInfo.Valid ) == "table" or type( paramInfo.Invalid ) == "table", "Command description (" .. name .. ") Params." .. param .. " must contain either a Valid or Invalid table." )
		local paramType = command:GetParameterType( param )
		for validity, paramValues in pairs( paramInfo ) do
			for i, paramValue in ipairs( paramValues ) do
				local okay, message = IsValidValueForType( paramValue, paramType )
				message = message or ""
				assert( okay, "Command description (" .. name .. ") Params." .. param .. "." .. validity .. "[" .. i .. "] " .. message )
			end
		end
	end
end

function ValidateDescriptions( deviceComm, descriptions )
	for _, description in ipairs( descriptions ) do
		ValidateDescription( deviceComm, description )
	end
end

--- In a call to Auto, the user is expected to provide a path to a command set and any number of <b>Command Descriptions</b>.
-- Command Descriptions can be a simple string, which will be interpreted as the name of the Command to run, or it can be a table of explicit configuration options.
-- <br/><br/>
-- <h3>Usage:</h3>
--
--<pre class="example">
--Auto "commandsets/mycommands.cmdset"<br/>
--{<br/>
--&nbsp;	"Command 1",<br/>
--&nbsp;	{ Name = "Command 2" },<br/>
--&nbsp;	{<br/>
--&nbsp;		Name = "Command 3",<br/>
--&nbsp;		Reqs = { "SR-123", "SR-456" },<br/>
--&nbsp;		Mode = "Write",<br/>
--&nbsp;		Verify = true,<br/>
--&nbsp;		Params =<br/>
--&nbsp;		{<br/>
--&nbsp;			Param1 = { Valid = { 1, 2, 3 }, Invalid = { 4, 5, 6 } },<br/>
--&nbsp;			ArrayParam = { Valid = { { 1, 2 }, { 3, 4 } }, Invalid = { { 4, 5 } } },<br/>
--&nbsp;		}<br/>
--&nbsp;	},<br/>
--&nbsp;	{ Pattern = "Command %d", Mode = "Do" },<br/>
--<br/>
--&nbsp;	Test = ...<br/>
--}</pre>
--
-- @class table
-- @name Command Descriptions
-- @field Name {string} The name of the command.<br/>
--	&nbsp; &nbsp; Either <code>Name</code> or <code>Pattern</code> must be specified.<br/>
--	&nbsp; &nbsp; Specifying a nonexistent command is an error.
-- @field Pattern {string} A pattern used to pull multiple commands from the command set and apply these options to all of them.<br/>
--	&nbsp; &nbsp; Either <code>Name</code> or <code>Pattern</code> must be specified.<br/>
--	&nbsp; &nbsp; This option overrides <code>Name</code>.
-- @field Reqs {table} [OPT] A table of strings used to link requirements to generated test cases.
-- @field Mode {string} [OPT] The mode to use for this command. ("<i>Do</i>", "<i>Write</i>", or "<i>Read</i>".)<br/>
--	&nbsp; &nbsp; Only needed if more than one mode is available.<br/>
--	&nbsp; &nbsp; If omitted, all available modes will be used.<br/>
--	&nbsp; &nbsp; Specifying an unavailable mode is an error.
-- @field Verify {boolean} If true, <code>AutoCheck</code> will run the command in <i>Read</i> mode and check that the returned values match those written in <code>AutoRun</code>.<br/>
--	&nbsp; &nbsp; Only valid on commands that are both <i>writable</i> and <i>readable</i>.<br/>
--	&nbsp; &nbsp; Requires that <code>Mode</code> is set to <i>Write</i>.
-- @field Params {table} A table of command parameters, each with subtables of <code>Valid</code> and <code>Invalid</code> values.<br/>
--	&nbsp; &nbsp; Specifying this table, even if it is empty, prevents automatic generation of parameters.<br/>
--	&nbsp; &nbsp; Therefore, if you use <code>Params</code> to specify values for a single parameter, the other parameters will not be tested for anything other than their default values.<br/>
--	&nbsp; &nbsp; Specifying nonexistent parameters is an error.<br/>
-- <br/>
-- @field Test The Test function here is different in that it takes an argument. AutoChronos will do some preprocessing and call this function with a <code>Command</code> object, set up according to what configuration options were passed in..
-- @field Setup The setup function. Called before the <code>Test</code> function.
-- @field Teardown The teardown function. Called after the <code>Test</code> function. This is called even if the <code>Test</code> fuction fails.

--- Creates an AutoChronos test. This will create test cases automatically and try to cover most if not all Commands in a CommandSet.
--	Use this instead of the TestCase function.
--	@param commandSet {string} The path to a CommandSet to be used to generate the test cases.
-- @see Command Descriptions
function Auto( commandSet )
	local deviceComm = DeviceComm.new( commandSet )
	return function( options )
		local testCases = { }
		local callbacks = FindCallbacks( options )
		local descriptions = NormalizeDescriptions( deviceComm, options )
		ValidateDescriptions( deviceComm, descriptions )
		local cases = GenerateCasesFromDescriptions( deviceComm, descriptions )
		local names = { }
		for _, case in ipairs( cases ) do
			local runMode = case.RunMode
			local parameterMode = case.ParameterMode
			local params = case.Params
			local verify = case.Verify
			local baseName = case.Name .. " (" .. runMode
			if verify then
				baseName = baseName .. "+Verify"
			end
			baseName = baseName .. ")"
			local name = baseName
			if names[ baseName ] then
				name = name .. " " .. names[ baseName ]
			end
			names[ baseName ] = ( names[ baseName ] or 1 ) + 1
			local testCase = TestCase( name )
			{
				Setup = callbacks.Setup,
				Teardown = callbacks.Teardown,
				Test = function()
					TrackRequirements( unpack( case.Reqs ) )
					autoRun = function( deviceComm, command )
						local result, message = pcall( function()
							return deviceComm[ runMode ]( deviceComm, command )
						end )
						if not result then
							AddFailure( message )
						else
							return message
						end
					end
					local command = deviceComm:FindCommand( case.Name )
					if verify then
						autoCheck = function( deviceComm, results )
							if type( results ) == "table" then
								local readResults = deviceComm:Read( command )
								Chronos.Actions.CheckEqual( results.Mem, readResults.Mem )
							end
						end
					end
					command[ parameterMode ] = params
					if callbacks.Test then
						callbacks.Test( command )
					end
					autoRun = ignore
					autoCheck = ignore
				end
			}
			table.insert( testCases, testCase )
		end
		return testCases
	end
end

---	The "Write" step of the test. The actual run mode may be "Do", "Write", or "Read". This is typically used in the Test() function, in the definition of an AutoChronos test case.
--	@param deviceComm {table} The DeviceComm object to use to run the tests.
--	@param command {table} The Command to run.
--	@see Command Descriptions
function AutoRun( deviceComm, command )
	if not deviceComm then
		error( "Must provide argument #1 to AutoRun" )
	end
	if not command then
		error( "Must provide argument #2 to AutoRun" )
	end
	return autoRun( deviceComm, command )
end

---	This is the "Read" step of the test. If the command under test has <b>Verify = true</b> (defaults to true for commands that are both writable and readable),
--	then this step will do a Read and then a CheckEqual to make sure that the returned values match the written values.
--	@param deviceComm {table} The DeviceComm object to use to run the tests.
--	@param results {table} The results returned from AutoRun. This contains all the results from a previous run.
--	@see Command Descriptions
function AutoCheck( deviceComm, results )
	if not deviceComm then
		error( "Must provide argument #1 to AutoCheck" )
	end
	return autoCheck( deviceComm, results )
end

GlobalExport( "Auto", "AutoRun", "AutoCheck" )
