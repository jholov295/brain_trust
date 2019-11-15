--Avanced/Persistence.lua
--[[
	TestSuite "Persistence"
--]]
dofile("LoadLibs.lua")

TestSuite "Persistence"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check Settings Persistence"
	{
	function()
		Pending()
		comment("Test saving preferences to the NVM")
	end
	},

	TestCase "Check Firmware Persistence"
	{
	function()
		Pending()
		comment("Test saving firmware to the NVM")
	end
	},

	TestCase "Check Changed Settings"
	{
	function()
		Pending()
		comment("Test changing preferences during communication")
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
