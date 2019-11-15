--Advanced/UART.lua
--[[
	TestSuite "SingleWire1"
	TestSuite "SingleWire2"
	TestSuite "Muxing"
	TestSuite "Flow Control"
	dofile("RevComm.lua")
	dofile("LIN.lua")
	dofile("Serial.lua")
	dofile("SDL.lua")
--]]
dofile("LoadLibs.lua")

TestSuite "SingleWire1"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check Fixed Thresholding"
	{
	function()
		Pending()
		comment("Test transmit or recieve using each pullup")
		Pending()
		comment("Test transmit or recieve at a different setting from the DAC")
	end
	},

	TestCase "Check Auto Thresholding"
	{
	function()
		Pending()
		comment("Test transmit or recieve using auto thresholding on only tester")
		Pending()
		comment("Test transmit or recieve using auto thresholding on only DUT")
		Pending()
		comment("Test transmit or recieve using auto thresholding on both")
	end
	},
	TestCase "Check Interaction with Reverse Line"
	{
	function()
		Pending()
		comment("Test SW2 interaction with reverse line  ?.")
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

TestSuite "SingleWire2"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check Fixed Thresholding"
	{
	function()
		Pending()
		comment("Test transmit or recieve at a different setting from the DAC")
	end
	},

	TestCase "Check Auto Thresholding"
	{
	function()
		Pending()
		comment("Test transmit or recieve using auto thresholding on only tester")
		Pending()
		comment("Test transmit or recieve using auto thresholding on only DUT")
		Pending()
		comment("Test transmit or recieve using auto thresholding on both")
	end
	},
	TestCase "Check Interaction with Reverse Line"
	{
	function()
		Pending()
		comment("Test SW2 interaction with reverse line.  ?")
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

TestSuite "Muxing"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check UART Muxing"
	{
	function()
		Pending()
		comment("Test that signals sent on one UART cannot be recieved by the other.")
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

TestSuite "Flow Control"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check UART Muxing"
	{
	function()
		Pending()
		comment("Test that signals sent on one UART cannot be recieved by the other.")
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

dofile(TestsPrefix .. "RevComm.lua")
dofile(TestsPrefix .. "LIN.lua")
dofile(TestsPrefix .. "Serial.lua")
dofile(TestsPrefix .. "SDL.lua")
