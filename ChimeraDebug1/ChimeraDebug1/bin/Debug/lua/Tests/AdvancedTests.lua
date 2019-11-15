require("Chronos")

dofile("LoadLibs.lua")

--[[These test suites perform in-depth testing of the Chimera system.  They are
	intended to be run using specialized hardware without user interaction, and are
	ideal for use on a continuous integration build path.  Like the basic tests, they
	attempt to exercise as much of the hardware as possible, but also use as much
	of the DeviceComm and firmware functionality as possible.  They assume that both
	Chimeras have good hardware.
--]]
--[=[ Outline of tests:
AdvancedTests.lua
	dofile("Advanced/CAN.Lua")
		TestSuite "Dedicated High Speed CAN"
		TestSuite "Multiplexed High Speed CAN"
		TestSuite "Multiplexed Singlewire CAN"
		TestSuite "Multiplexed Auxilary CAN"
		TestSuite "Unmuxed CAN2 Lines"
		TestSuite "Error Handling"
		TestSuite "Voltage Monitoring"
	dofile("Advanced/UART.Lua")
		TestSuite "SingleWire1"
		TestSuite "SingleWire2"
		TestSuite "Muxing"
		TestSuite "Flow Control"
		dofile("RevComm.lua")
			TestSuite "RevComm"
		dofile("LIN.lua")
			TestSuite "LIN"
		dofile("Serial.lua")
			TestSuite "RS232"
			TestSuite "RS422"
			TestSuite "RS485"
		dofile("SDL.lua")
			TestSuite "SDL"
	dofile("Advanced/AuxIO.lua")
		TestSuite "Switches and LEDs"
		TestSuite "Open Collectors"
		TestSuite "Analog to Digital Converters"
		TestSuite "General Purpose IO"
	dofile("Advanced/I2C.lua")
		TestSuite "I2C"
	dofile("Advanced/SPI.lua")
		TestSuite "SPI"
	dofile("Advanced/Dallas.lua")
		TestSuite "Dallas"
	dofile("Advanced/Hardware.lua")
		TestSuite "Voltage Regulation"
		TestSuite "1.2V Reference Voltage"
		TestSuite "High Power Outputs"
	dofile("Advanced/Periodics.lua")
		TestSuite "Periodics"
	dofile("Advanced/Persistence.lua")
		TestSuite "Persistence"
	dofile("Advanced/Simultaneous.lua")
		TestSuite "Simultaneous Communication"
--]=]
dofile(TestsPrefix .. "CAN.lua")
dofile(TestsPrefix .. "UART.lua")
dofile(TestsPrefix .. "AuxIO.lua")
dofile(TestsPrefix .. "I2C.lua")
dofile(TestsPrefix .. "SPI.lua")
dofile(TestsPrefix .. "Dallas.lua")
dofile(TestsPrefix .. "Hardware.lua")
dofile(TestsPrefix .. "Periodics.lua")
dofile(TestsPrefix .. "Persistence.lua")
dofile(TestsPrefix .. "Simultaneous.lua")



