--Advanced/[UART]/SDL.lua
--This is generally used with SingleWire2, but can probably also be used with SingleWire1
--[[
	TestSuite "SDL"
--]]
dofile("LoadLibs.lua")

TestSuite "SDL"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check SDL"
	{
	function()
		Pending()
		comment("Can't test SDL without broadcast ability")
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
