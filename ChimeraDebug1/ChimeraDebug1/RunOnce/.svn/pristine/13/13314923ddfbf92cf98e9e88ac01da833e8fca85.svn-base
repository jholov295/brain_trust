--Advanced/SPI.lua
--[[
	TestSuite "SPI"
--]]
dofile("LoadLibs.lua")

TestSuite "SPI"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check SPI"
	{
	function()
		Pending()
		comment("Test Suite written only if a hardware change allows slave configuration for Chimera.")
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
