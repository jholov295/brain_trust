--Avanced/Simultaneous.lua
--[[
	TestSuite "Simultaneous"
--]]
dofile("LoadLibs.lua")

TestSuite "Simultaneous Communication"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check Simultaneous Communication"
	{
	function()
		Pending()
		comment("Test Simultaneous Communication over various channels and protocols")
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
