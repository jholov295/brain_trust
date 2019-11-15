--Advanced/Hardware.lua
--[[
	TestSuite "Voltage Regulation"
	TestSuite "1.2V Reference Voltage"
	TestSuite "High Power Outputs"
--]]
dofile("LoadLibs.lua")

TestSuite "Voltage Regulation"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check 3.3V Regulation"
	{
	function()
		Pending()
		comment("Test 3.3V Regulation with other HW")
	end
	},

	TestCase "Check 5V Regulation"
	{
	function()
		Pending()
		comment("Test 5V Regulation with other HW")
	end
	},

	TestCase "Check Unregulated voltage shutoff"
	{
	function()
		Pending()
		comment("Test Vunreg shutoff at 18V (Will require other HW and isolation.)")
		--This may seem like just a HW test, but it really tests the error reporting of the board
		--under different voltage levels.  What still functions at 24V?
	end
	},

	EachTeardown = function()
		io.write("\n", string.rep(" ", indent))
	end,

	Teardown = function()
		dec()
		--comment("End of test suite.", 0)
		dec()
	end,
}

TestSuite "1.2V Reference Voltage"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check 1.2V Reference Voltage"
	{
	function()
		Pending()
		comment("Test 3.3V Regulation with other HW")
	end
	},

	EachTeardown = function()
		io.write("\n", string.rep(" ", indent))
	end,

	Teardown = function()
		dec()
		--comment("End of test suite.", 0)
		dec()
	end,
}

TestSuite "High Power Outputs"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check Reverse On/Off/Open"
	{
	function()
		Pending()
		comment("Test 3.3V Regulation with other HW")
	end
	},

	TestCase "Check Ignition On/Off/Open"
	{
	function()
		Pending()
		comment("Test 3.3V Regulation with other HW")
	end
	},

	TestCase "Check Battery On/Off/Open"
	{
	function()
		Pending()
		comment("Test 3.3V Regulation with other HW")
	end
	},

	EachTeardown = function()
		io.write("\n", string.rep(" ", indent))
	end,

	Teardown = function()
		dec()
		--comment("End of test suite.", 0)
		dec()
	end,
}
