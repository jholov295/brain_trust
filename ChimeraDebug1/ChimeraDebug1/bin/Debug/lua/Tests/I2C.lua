--Advanced/I2C.lua
--[[
	TestSuite "I2C"
--]]
dofile("LoadLibs.lua")

TestSuite "I2C"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check I2C"
	{
	function()
		Pending()
		comment("Test Suite written only when slave I2C mode is developed for the Chimera")
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
