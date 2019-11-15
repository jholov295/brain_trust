--Advanced/[UART.lua]/Serial.lua
--The RS### protocols have enough similarity that they can go in the same file, like the various muxed CAN tests.
--[[
	TestSuite "RS232"
	TestSuite "RS422"
	TestSuite "RS485"
--]]
dofile("LoadLibs.lua")

TestSuite "RS232"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check Transmission"
	{
	function()
		Pending()
		comment("Test transmit")
	end
	},

	TestCase "Check Reception"
	{
	function()
		Pending()
		comment("Test recieve")
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
--]]

TestSuite "RS422"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check Transmit and Recieve"
	{
	function()
		Pending()
		comment("Can't test RS422 without transmitter")
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
--]]
TestSuite "RS485"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check Transmission"
	{
	function()
		Pending()
		comment("Test transmit")
	end
	},

	TestCase "Check Reception"
	{
	function()
		Pending()
		comment("Test recieve")
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
--]]
