--Advanced/Dallas.lua
--[[
	TestSuite "Dallas"
--]]
dofile("LoadLibs.lua")

TestSuite "Dallas"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check Dallas"
	{
	function()
		Pending()
		comment("Test Suite written only when Dallas one wire is developed for the Chimera. ")
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
