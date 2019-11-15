--Avanced/Periodics.lua
--[[
	TestSuite "Periodics"
--]]
dofile("LoadLibs.lua")

TestSuite "Periodics"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check Periodics"
	{
	function()
		Pending()
		comment("Test using the Periodics functionality")
		comment("Test entire program using the PeriodicAwesomeness branch")
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
