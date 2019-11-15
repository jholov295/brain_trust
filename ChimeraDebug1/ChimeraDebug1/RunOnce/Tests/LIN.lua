--Advanced/[UART]/(SingleWire2)/LIN.lua
--This is generally used with SingleWire2, but should also be tested with SingleWire1
--[[
	TestSuite "LIN"
--]]
dofile("LoadLibs.lua")

TestSuite "LIN"
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
		comment("Test Transmit and recieve using LIN")
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
