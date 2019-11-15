package.path = package.path .. ";?/init.lua;../?/init.lua;../?.lua"
require "Chronos"

function GetAcceptableValues()
	return { 4, 5, 6 }
end

function OpenConnection()
	return { Closed = false }
end

function CloseConnection( handle )
	CheckTimeMax( 10, function() -- This ends up taking longer than we expect.
		local start = os.clock()
		while os.difftime( os.clock(), start ) < 1 do
		end
		handle.Closed = true
	end )
end

function GetStatus( value )
	return value ~= 5
end

local acceptableValues
local handle

TestSuite "My Test Suite"
{
	Version = "Thu Jul  1 14:42:39 2010",

	TestCase "My Test Case - Expect Fail Status"
	{
		Setup = function()
			acceptableValues = GetAcceptableValues()
			CheckEqual( 3, #acceptableValues ) -- We should get three acceptable values.
			handle = OpenConnection()
			Check( handle )
		end,

		function()
			local myValue = 5
			local badValue = 5
			CheckSequence( myValue, acceptableValues )
			CheckNotEqual( badValue, myValue )
			local status = GetStatus( myValue )
			Check( status )
		end,

		Teardown = function()
			CloseConnection( handle ) -- Must close the connection even if the test ends prematurely.
		end,
	},

	TestCase "My Second Test Case - Expect Fail Status"
	{
		function()
			AddComment( "Make sure this is before any Checks*(). This tickles a bug found checking the status." )
			local expected = { Cities = { "London", "New York", "Paris" }, International = true }
			local actual = { Cities = { "Detroit", "New York" } }
			CheckEqual( expected, actual )
			--AddComment( "some AddComment() comment." )
			Check( true )
		end,
	},

	TestCase "GetName"
	{
		function()
			local ts = Chronos.CurrentTestAccumulator.TestSuites[ "My Test Suite" ]
			Check( ts )
			CheckEqual( "My Test Suite", ts:GetName() )
			local tc = ts.TestCases[ "GetName" ]
			Check( tc )
			CheckEqual( "GetName", tc:GetName() )
			CheckEqual( nil, tc:GetVersion() )
		end,
	},

	TestCase "GetVersion"
	{
		Version = 1.0,

		function()
			local ts = Chronos.CurrentTestAccumulator.TestSuites[ "My Test Suite" ]
			Check( ts )
			CheckEqual( "Thu Jul  1 14:42:39 2010", ts:GetVersion() )
			local tc = ts.TestCases[ "GetVersion" ]
			Check( tc )
			local actual = tc:GetVersion()
			CheckEqual( 1.0, actual )
		end,
	},

	TestCase "AddComment - Beginning Pending Test Case - Expect Pass Status"
	{
		function()
			Pending()
			Check( true )
			AddComment( "Make sure this is before any Checks*(). This tickles a bug found checking the status." )
			Check( true )
		end,
	},

	TestCase "AddComment - End Pending Test Case - Expect Pending Status"
	{
		function()
			Check( true )
			AddComment( "Make sure this is before any Checks*(). This tickles a bug found checking the status." )
			Check( true )
			Pending()
		end,
	},

	TestCase "Empty Pending Expected Test Case - Expect Pending Status"
	{
		function()
		end,
	},

	TestCase "Only AddComment Test Case - Expect Pending Status"
	{
		function()
			AddComment( "Make sure this is before any Checks*(). This tickles a bug found checking the status." )
		end,
	},
}

