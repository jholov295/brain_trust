--Advanced/[UART.lua]/(SingleWire1)/RevComm.lua
--This is generally used with SingleWire1, but should also be tested with SingleWire2
--[[
	TestSuite "RevComm"
--]]
dofile("LoadLibs.lua")

TestSuite "RevComm"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check RevComm"
	{
	function()
		Pending()
		comment("Test Transmit and recieve using RevComm")
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
