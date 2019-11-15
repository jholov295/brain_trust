--Advanced/CAN.lua
--[[
	TestSuite "Dedicated High Speed CAN"
	TestSuite "Multiplexed High Speed CAN"
	TestSuite "Multiplexed Singlewire CAN"
	TestSuite "Multiplexed Auxilary CAN"
	TestSuite "Unmuxed CAN2 Lines"
	TestSuite "Error Handling"
	TestSuite "Voltage Monitoring"
--]]
dofile("LoadLibs.lua")

TestSuite "Dedicated High Speed CAN"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check Transfers"
	{
	function()
		Pending()
		comment("Test one/few byte transfer - done in basic tests")
		comment("Test multi-packet transer")
		end
	},

	TestCase "Check Bitrates"
	{
	function()
		Pending()
		comment("Test at variable bitrates (40kb to 1Mb)")
		--Watch out for equal overflows/missed settings!  Verify with oscope before publishing.
	end
	},

	TestCase "Check Identifiers"
	{
	function()
		Pending()
		comment("Test using destination/source IDs")
		comment("Test differently sized destination/source IDs")
		comment("Test wrong destination/source IDs")
		end
	},

	TestCase "Check Flow Control"
	{
	function()
		Pending()
		comment("Test flow control block sizes")
		comment("Test flow control times")
		end
	},

	TestCase "Check Frame Size Padding"
	{
	function()
		Pending()
		comment("Test padding to frame size")
		comment("Test not padding to frame size")
	end
	},

	TestCase "Check Prefixes and Suffixes"
	{
	function()
		Pending()
		comment("Test adding prefixes")
		comment("Test adding suffixes")
	end
	},

	TestCase "Check PCI byte"
	{
	function()
		Pending()
		comment("Test Using or not using PCI byte")
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

TestSuite "Multiplexed High Speed CAN"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check Transfers"
	{
	function()
		Pending()
		comment("Test one/few byte transfer - done in basic tests")
		comment("Test multi-packet transer")
		end
	},

	TestCase "Check Bitrates"
	{
	function()
		Pending()
		comment("Test at variable bitrates (40kb to 1Mb)")
		--Watch out for equal overflows/missed settings!  Verify with oscope before publishing.")
	end
	},

	TestCase "Check Identifiers"
	{
	function()
		Pending()
		comment("Test using destination/source IDs")
		comment("Test differently sized destination/source IDs")
		comment("Test wrong destination/source IDs")
		end
	},

	TestCase "Check Flow Control"
	{
	function()
		Pending()
		comment("Test flow control block sizes")
		comment("Test flow control times")
		end
	},

	TestCase "Check Frame Size Padding"
	{
	function()
		Pending()
		comment("Test padding to frame size")
		comment("Test not padding to frame size")
	end
	},

	TestCase "Check Prefixes and Suffixes"
	{
	function()
		Pending()
		comment("Test adding prefixes")
		comment("Test adding suffixes")
	end
	},

	TestCase "Check PCI byte"
	{
	function()
		Pending()
		comment("Test Using or not using PCI byte")
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
TestSuite "Multiplexed Low Speed CAN"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check Muxed Low Speed CAN"
	{
	function()
		Pending()
		comment("Test everything the Unmuxed CAN did")
	end
	},

	TestCase "Check Error Handling"
	{
	function()
		Pending()
		comment("Test error line")
	end
	},

	TestCase "Check One Wire mode"
	{
	function()
		Pending()
		comment("Test one wire mode under error condition")
		--May require other HW
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
TestSuite "Multiplexed Singlewire CAN"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check Muxed Singlewire CAN"
	{
	function()
		Pending()
		comment("Test everything the Unmuxed CAN did.")
	end
	},

	TestCase "Check High Voltage Wakeup"
	{
	function()
		Pending()
		comment("Test high voltage wakeup.")
	end
	},

	TestCase "Check C1W Wire"
	{
	function()
		Pending()
		comment("Test C1W.")
		--This is from the testing document - Is C1W different from Singlewire CAN?
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
TestSuite "Multiplexed Auxilary CAN"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check Muxed Auxilary CAN"
	{
	function()
		Pending()
		comment("Test everything the other CANs did")
	end
	},

	--Other tests dependent on aux CAN HW - Don't test the HW, test the muxing!

	EachTeardown = function()
		io.write("\n", string.rep(" ", indent))
	end,

	Teardown = function()
		dec()
		--comment("End of test suite.", 0)
		dec()
	end,
}
TestSuite "Unmuxed CAN2 Lines"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,


	TestCase "Check Unmuxed CAN2 Lines"
	{
	function()
		Pending()
		comment("Test C1W, CANMOD, HS CAN, LS CAN, SW CAN on 34-pin (unmuxed) connector")
		--CANMOD will require other HW
		comment("Test that unmuxed signals do not cross over")
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
TestSuite "Error Handling"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check CAN Error Reporting"
	{
	function()
		Pending()
		comment("Test Error recovery - No hard resets!")
		comment("Test Error reporting")
		comment("Test with simulated long/untwisted/noisy bus")
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

TestSuite "Voltage Monitoring"
{
	Setup = function()
		inc()
		--comment("Start of test suite.\n")
		inc()
	end,

	TestCase "Check Voltage Monitoring"
	{
	function()
		Pending()
		comment("Test voltage monitoring (May require external HW?)")
		Pending()
		comment("Test that unmuxed signals do not cross over")
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
