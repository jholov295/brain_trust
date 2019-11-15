--- Utility for generating check functions according to certain conventions.
-- <pre class="example">
-- MakeCheck "Check123"<br/>
-- {<br/>
-- &nbsp; Formatter = { Chronos.ToString, Hex = Chronos.ToHexString },<br/>
-- &nbsp; Args = { "one", "two", "three" },<br/>
-- &nbsp; Types = { one = "number", two = "number", three = "number" },<br/>
-- &nbsp; PseudoArgs =<br/>
-- &nbsp; {<br/>
-- &nbsp; &nbsp; sum = function( args )<br/>
-- &nbsp; &nbsp; &nbsp; return args.one + args.two + args.three<br/>
-- &nbsp; &nbsp; end<br/>
-- &nbsp; },<br/>
-- &nbsp; PassIf = function( args )<br/>
-- &nbsp; &nbsp; return args.one == 1 and args.two == 2 and args.three == 3<br/>
-- &nbsp; end,<br/>
-- &nbsp; Expected = "$( { 1, 2, 3 } )",<br/>
-- &nbsp; Actual = "$( { one, two, three } )",<br/>
-- &nbsp; FailureMessage = "Expected $( { 1, 2, 3 } ) but was $( { one, two, three } ) with sum $( sum )"<br/>
-- }<br/>
-- </pre>
module( "Chronos.Actions.MakeCheck", package.seeall )

require "Chronos/GlobalExport"

CheckData = { }

function MetaCheck( name, formatter )
	local options = CheckData[ name ]
	if not options then
		error( "Check not found." )
	end
	formatter = formatter or ""
	formatter = options.Formatter[ formatter ]
	if not formatter then
		error( "No formatter found" )
	end
	return
	{
		Prototype = function( ... )
			return ProcessArgs( name, formatter, options, ... ).Prototype
		end,
		PassIf = function( ... )
			local data = ProcessArgs( name, formatter, options, ... )
			local result = options.PassIf( data.Args )
			if type( result ) == "thread" then
				return HandleCoroutine( result, { Args = options.Args, PseudoArgs = options.PseudoArgs, Formatter = formatter, Message = data.Message, BaseFailureMessage = data.BaseFailureMessage } )
			end
			return result
		end,
		FailureMessage = function( ... )
			local data = ProcessArgs( name, formatter, options, ... )
			local result = options.PassIf( data.Args )
			local messages = { }
			if type( result ) == "thread" then
				local function f( message )
					table.insert( messages, message )
				end
				HandleCoroutine( result, { Args = options.Args, PseudoArgs = options.PseudoArgs, Formatter = formatter, Message = data.Message, BaseFailureMessage = data.BaseFailureMessage, Hook = f } )
			elseif result == false then
				local failureMessage = FailureMessage { FailureMessage = options.FailureMessage, Message = data.Message, Name = name, Environment = data.Environment }
				table.insert( messages, failureMessage )
			end
			return unpack( messages )
		end,
		Expected = function( ... )
			return ProcessArgs( name, formatter, options, ... ).Expected
		end,
		Actual = function( ... )
			return ProcessArgs( name, formatter, options, ... ).Actual
		end,
		Action = function( ... )
			local data = ProcessArgs( name, formatter, options, ... )
			return Chronos.Action.new( data.Prototype, { Expected = data.Expected, Actual = data.Actual } )
		end
	}
end

function MakeCheckDefaults( options )
	if not options then
		error( "No options provided." )
	end
	if not options.PassIf then
		error( "No PassIf argument provided." )
	end
	options.Expected = tostring( options.Expected or "$( expected )" )
	options.Actual = tostring( options.Actual or "$( actual )" )
	options.Args = options.Args or { }
	options.Types = options.Types or { }
	options.PseudoArgs = options.PseudoArgs or { }
	options.Formatter = options.Formatter or Chronos.ToString
	if type( options.Formatter ) == "function" then
		options.Formatter = { options.Formatter }
	end
	if options.Formatter[ 1 ] then
		options.Formatter[ "" ] = options.Formatter[ 1 ]
		options.Formatter[ 1 ] = nil
	end
	return options
end

Conversions =
{
	boolean = function( value )
		if value then
			return true
		end
		return false
	end,
	string = function( value )
		return tostring( value )
	end,
	number = function( value )
		return tonumber( value )
	end
}

function MapArgs( args, map )
	local mappedArgs = { }
	for argIndex, argName in ipairs( map ) do
		mappedArgs[ argName ] = args[ argIndex ]
	end
	return mappedArgs, select( #map + 1, unpack( args ) )
end

function EnforceTypes( args, types )
	for argName, expectedType in pairs( types ) do
		local argValue = args[ argName ]
		local actualType = type( argValue )
		if expectedType ~= actualType then
			local converter = Conversions[ expectedType ]
			local converted = nil
			if converter then
				converted = converter( argValue )
			end
			if converted == nil then
				error( "Argument '" .. argName .. "' expected to be of type " .. expectedType .. " but was of type " .. actualType .. " (" .. Chronos.ToString( argValue ) .. ")" )
			end
			args[ argName ] = converted
		end
	end
end

function AddPseudoArgs( args, pseudoArgs )
	for pseudoName, pseudoFunction in pairs( pseudoArgs ) do
		args[ pseudoName ] = pseudoFunction( args )
	end
end

function FormatArgs( args, formatter, expectedArgs )
	local formattedArgs = { }
	for argName, argValue in pairs( args ) do
		formattedArgs[ argName ] = formatter( argValue )
	end
	for _, expectedArg in ipairs( expectedArgs ) do
		if formattedArgs[ expectedArg ] == nil then
			formattedArgs[ expectedArg ] = formatter( nil )
		end
	end
	return formattedArgs
end

function Preprocess( string, environment )
	return assert( LuaPP.preprocess { input = string, output = "string", lookup = environment, strict = false } )
end

function Prototype( name, map, formattedArgs )
	local argList = { }
	local prototype = name .. "( "
	for argIndex, argName in ipairs( map ) do
		table.insert( argList, argName .. " = " .. formattedArgs[ argName ] )
	end
	return name .. "( " .. table.concat( argList, ", " ) .. " )"
end

function Environment( formattedArgs )
	return setmetatable( formattedArgs, { __index = _G } )
end

function HandleCoroutine( result, options )
	local argMap = options.Args
	local pseudoArgs = options.PseudoArgs
	local formatter = options.Formatter
	local message = options.Message
	local baseFailureMessage = options.BaseFailureMessage
	local hook = options.Hook or Chronos.Actions.AddFailure
	local noFailure = true
	while coroutine.status( result ) ~= "dead" do
		local status, args = assert( coroutine.resume( result ) )
		if args then
			local customFailureMessage = args[ 1 ]
			for pseudoName, pseudoFunction in pairs( pseudoArgs ) do
				args[ pseudoName ] = pseudoFunction( args )
			end
			local formattedArgs = FormatArgs( args, formatter, argMap )
			failureMessage = baseFailureMessage .. " " .. Preprocess( customFailureMessage, Environment( formattedArgs ) )
			if message then
				failureMessage = message .. " (" .. failureMessage .. ")"
			end
			hook( failureMessage, 3 )
			noFailure = false
		end
	end
	return noFailure
end

function FailureMessage( options )
	local baseFailureMessage = options.Name .. " failed!"
	local fullFailureMessage = baseFailureMessage
	if options.FailureMessage then
		fullFailureMessage = fullFailureMessage .. " " .. Preprocess( options.FailureMessage, options.Environment )
	end
	if options.Message then
		fullFailureMessage = options.Message .. " (" .. fullFailureMessage .. ")"
	end
	return fullFailureMessage
end

function ProcessArgs( name, formatter, options, ... )
	local baseFailureMessage = name .. " failed!"
	local args, message = MapArgs( { ... }, options.Args )
	EnforceTypes( args, options.Types )
	AddPseudoArgs( args, options.PseudoArgs )
	local formattedArgs = FormatArgs( args, formatter, options.Args )
	local environment = Environment( formattedArgs )
	local expected = Preprocess( options.Expected, environment )
	local actual = Preprocess( options.Actual, environment )
	local prototype = Prototype( name, options.Args, formattedArgs )
	return
	{
		Args = args,
		Prototype = prototype,
		Expected = expected,
		Actual = actual,
		BaseFailureMessage = baseFailureMessage,
		Message = message,
		Environment = environment
	}
end

--- Makes the body of a check function, given a name and table of options. If more than one formatter is given, multiple check functions will be generated with different suffixes.
-- <br/><br/>
-- All arguments are optional except for PassIf. LuaPP strings have access to all arguments and pseudo-arguments.
-- <ul>
-- <li>Actual: A LuaPP string used for generating action data. Defaults to $( actual ).</li>
-- <pre class="example"> Actual = "$( condition )"</pre>
-- <li>Args: An array of argument names used to map function arguments to named arguments.</li>
-- <pre class="example"> Args = { "expected", "actual" }</pre>
-- <li>Expected: A LuaPP string used for generating action data. Defaults to $( expected ).</li>
-- <pre class="example"> Expected = "> $( min )"</pre>
-- <li>FailureMessage: A LuaPP string used for generating failure messages.</li>
-- <pre class="example"> FailureMessage = "Something went wrong with $( nuclearReactor ), meltdown in $( meltdownTime ) seconds"</pre>
-- <li>Formatter</li>
-- Either a single function used to format values, or a table where the first array index is the default formatter and named indices specify additional variations of the check using different functions.
-- <pre class="example"> Formatter = Chronos.ToString<br/>
-- or<br/>
-- Formatter = { Chronos.ToString, Hex = Chronos.ToHexString }</pre>
-- <li>PassIf: A function which accepts the check's arguments and returns true if the check should pass.</li>
-- <br/>Alternatively, this function can return a coroutine which is expected to yield a table for every failure in this format:<br/>
-- { "LuaPP failure message", argName1 = argValue1, argName2 = argValue2, ... }
-- <pre class="example">
-- PassIf = function( args )<br/>
-- &nbsp; return args.expected == args.actual<br/>
-- end<br/>
-- or<br/>
-- PassIf = function( args )<br/>
-- &nbsp; return coroutine.create( function()<br/>
-- &nbsp; &nbsp; if args.one ~= 1 then<br/>
-- &nbsp; &nbsp; &nbsp; coroutine.yield { "Expected $( expected ) but was $( actual )", expected = 1, actual = args.one }<br/>
-- &nbsp; &nbsp; end<br/>
-- &nbsp; &nbsp; if args.two ~= 2 then<br/>
-- &nbsp; &nbsp; &nbsp; coroutine.yield { "Expected $( expected ) but was $( actual )", expected = 2, actual = args.two }<br/>
-- &nbsp; &nbsp; end<br/>
-- &nbsp; end )<br/>
-- end</pre>
-- <li>PseudoArgs: A table of names to functions that will accept mapped args and return new "pseudo-args" that can be referenced from other hooks.</li>
-- <pre class="example">
-- PseudoArgs =<br/>
-- {<br/>
-- &nbsp; magic = function( args )<br/>
-- &nbsp; &nbsp; return args.spells + args.sorcery<br/>
-- &nbsp; end<br/>
-- }</pre>
-- <li>Types: A table of argument names to types. Generated function will attempt to convert types and error out if conversion fails.</li>
-- <pre class="example"> Types = { expected = "number", actual = "number" }</pre>
-- </ul>
-- @param name The name of the check. For example, Check123.
-- @return A function which accepts all arguments beyond the name argument.
function MakeCheck( name )
	return function( options )
		options = MakeCheckDefaults( options )
		Chronos.Actions.MakeCheck.CheckData[ name ] = options
		for functionSuffix, formatter in pairs( options.Formatter ) do
			local func = function( ... )
				local data = ProcessArgs( name, formatter, options, ... )
				Chronos.Actions.AddAction( data.Prototype, { Expected = data.Expected, Actual = data.Actual } )
				local result = options.PassIf( data.Args )
				if type( result ) == "thread" then
					return HandleCoroutine( result, { Args = options.Args, PseudoArgs = options.PseudoArgs, Formatter = formatter, Message = data.Message, BaseFailureMessage = data.BaseFailureMessage } )
				elseif result == true then
					return true
				elseif result == false then
					local failureMessage = FailureMessage { FailureMessage = options.FailureMessage, Message = data.Message, Name = name, Environment = data.Environment }
					Chronos.Actions.AddFailure( failureMessage, 2 )
					return false
				end
				error( "PassIf must return a boolean indicating the success of the check." )
			end
			local functionName = name .. functionSuffix
			Chronos.Actions.Checks[ functionName ] = func
			_G[ functionName ] = func
		end
	end
end

GlobalExport( "MakeCheck" )

