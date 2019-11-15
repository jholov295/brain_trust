--Advanced/AuxIO.lua
--[[
	TestSuite "Switches and LEDs"
	TestSuite "Open Collectors"
	TestSuite "Analog to Digital Converters"
	TestSuite "General Purpose IO"
--]]
dofile("LoadLibs.lua")

TestSuite "Switches and LEDs"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check Switches"
	{
	function()
		Pending()
		comment("Test switches after exposing functionality (feat. 1601)")
	end
	},

	TestCase "Check LEDs"
	{
	function()
		Pending()
		comment("Test LEDs after exposing functionality (feat. 1601)")
		comment("Include ablility to read LEDs in case of a fault.")
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



TestSuite "Open Collectors"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check Open Collectors"
	{
	function()
		Pending()
		comment("Test open collectors using RG15 and OCs shorted together.")
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



TestSuite "Analog to Digital Converters"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check ADCs"
	{
	function()
		Pending()
		comment("Test the general purpose A/D converters.")
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


TestSuite "General Purpose IO"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check GPIO"
	{
	function()
		Pending()
		comment("Test the 8-bit general purpose IO.")
	end
	},

	TestCase "Check RG15."
	{
	function()
		Pending()
		comment("Test the random RG15 line")
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
