--[[ Are these bugs, or bad tests/syntax/applications?
	Socket receive Timed out! (AsioTimeoutEx: c:\BuildAgent\work\gScripted\boost_utils\boost/asio/read_with_timeout.hpp@211)
	Occasional: Timeout waiting for erase to complete. (ChimeraEx: .\hardware\chimeraFirmware\ChimeraFirmware.cpp@487)
	Output does not work when given valid XML files.
	Random "Error: Chimera did not respond. Is it connected?" failures.
	Random "Timeout waiting for Ack to (data or 'empty') id=blah. Decoded. 11bit, TxData | Do( SendData )
	Error: Timeout | Do( ReadData )
	Error: LIN Slave did not respond. | Do( ReadData )       (Lin only...)
--]]


dofile( "Utilities.lua" )
require("gScripted")
require("Chronos")
dofile("setup.lua")

--[[ Gets new firmware from a URL.

	The URL can be local:
	UpdateFirmware("C:/ChimeraFirmware/chimera.hex")
	or it can be on the LAN/WWW:
	UpdateFirmware("http://eeweb/svn/testers/deployment/firmware/Chimera/chimera.hex").

	This script is triggered by a source code change, so we will have a new hex file and
	don't need to do a version comparison.  Flashing new firmware every time is annoying for
	testing when no firmware is available, so I added a prompt.
-]]
function UpdateFirmware(URL)
	if (type(URL) ~= "string") then
		error("URL must be a string.")
		exit()
	end

	print("Updating firmware from:\n", URL)

	--Set up DCs
	testerCommandSettings, testeeCommandSettings,
	testerUserSettings, testeeUserSettings = getDefaultSettings()
	testerUserSettings.ChimeraCan.IP = "10.1.1.3"
	setModifiedSettings("ChimeraCan",
						testerCommandSettings, testeeCommandSettings,
						testerUserSettings, testeeUserSettings)
	print("Initialized Chimera DCs")

	--Get old versions
	local resultTester = testerDC:Do( "GetVersion" )
	local resultTestee = testeeDC:Do( "GetVersion" )
	print("Current Versions are:\n\tTester: " .. resultTester["Version"] .. "\n\tTestee: " .. resultTestee["Version"])

	--Update versions
	print("Flashing firmware.  Please wait (may take up to 60 seconds) ...")


	-- Must convert between string and U8 Vector for UpdateFirmware hardware command
	-- Commands only deal in numbers and arrays.
	-- For example, the deployment firmware at:
	-- "http://eeweb/svn/testers/deployment/firmware/Chimera/chimera.hex"
	-- must be
	-- {, 0x68, 0x74, 0x74, 0x70, 0x3A, 0x2F, 0x2F, 0x65, 0x65, 0x77, 0x65 ... 0x78}
	local URL_V = {}

	for i = 1, string.len(URL) do
		URL_V[i] = string.byte(URL, i)
	end

	testerDC:Do("UpdateFirmware", {Path = URL_V})
	print("Updated tester.")
	testeeDC:Do("UpdateFirmware", {Path = URL_V})
	print("Updated testee.")

	sleep(1)

	--Get new versions
	local resultTester = testerDC:Do( "GetVersion" )
	local resultTestee = testeeDC:Do( "GetVersion" )

	print("Current Versions are:\n\tTester: " .. resultTester["Version"] .. "\n\tTestee: " .. resultTestee["Version"])

end

print("Do you want to update the firmware?")
local l = io.read("*line")
if yes(l) then
	-- This is the location of the deployed firmware.
	UpdateFirmware("http://eeweb/svn/testers/deployment/firmware/Chimera/chimera.hex")
	-- We want to update from the most recently built firmware.
	-- This will come from the project source at http://eeweb/svn/tools/projects/Chimera/
	--UpdateFirmware("C:/ChimeraFirmware/chimera.hex")
else
	print("Firmware will not be updated.")
	sleep(.4)
end

--[=[Tester Connection - Made obsolete by firmware flashing above.
--[[ Verify Connection to Tester
 This test suite simply reads the MACAddress of the tester,
 and verifies that it is not nil.  This verifies that a Chimera is
 set up to have the IP address 10.1.1.3, is connected, and is powered on.
--]]
TestSuite "ConnectTester"
{
	Setup = function()

		testerCommandSettings, testeeCommandSettings,
		testerUserSettings, testeeUserSettings = getDefaultSettings()
		testerUserSettings.ChimeraCan.IP = "10.1.1.3"
		setModifiedSettings("ChimeraCan",
							testerCommandSettings, testeeCommandSettings,
							testerUserSettings, testeeUserSettings)
	end,

	TestCase "GetVersion"
	{
	function()
		local result = testerDC:Do( "GetVersion" )
		CheckNotEqual(nil, result["Version"])
	end
	},

	Teardown = function()
		testerDC:Shutdown()
	end,
}
--]=]
--[=[Testee Connection - Made obsolete by firmware flashing above.
--[[Verifcd y Connection to Testee
 The testee is assumed to have the default IP address of 10.1.1.2.

 This test suite simply reads the MACAddress of the testee.
 and verifies that it is not nil.  This verifies that a Chimera is
 set up to have the IP address 10.1.1.2, is connected, and is powered on.
--]]
TestSuite "ConnectTestee"
{
	Setup = function()
		testerCommandSettings, testeeCommandSettings,
		testerUserSettings, testeeUserSettings = getDefaultSettings()
		setModifiedSettings("ChimeraCan",
							testerCommandSettings, testeeCommandSettings,
							testerUserSettings, testeeUserSettings)
	end,

	TestCase "GetVersion"
	{
	function()
		local result = testeeDC:Do( "GetVersion" )
		CheckNotEqual(nil, result["Version"])
	end
	},

	Teardown = function()
		testeeDC:Shutdown()
	end,
}
--]=]

--[ =[Dedicated CAN
--[[ Verify Dedicated Can transciever
 This test suite transmits and receives data using the CAN1 port.
--]]
TestSuite "ChimeraCanDedicated"
{
	Setup = function()
	end,


	EachSetup = function()
	end,

	TestCase "Receive"
	{

	function()
		testerCommandSettings, testeeCommandSettings,
		testerUserSettings, testeeUserSettings = getDefaultSettings()
		--Changes occur here
		testerCommandSettings.CAN.Transceiver = 1
		testeeCommandSettings.CAN.Transceiver = 1

		testerUserSettings.ChimeraCan.IP = "10.1.1.3"

		testerUserSettings.ChimeraCan.CanPort = "HighSpeed"
		testeeUserSettings.ChimeraCan.CanPort = "HighSpeed"

		setModifiedSettings("ChimeraCan",
							testerCommandSettings, testeeCommandSettings,
							testerUserSettings, testeeUserSettings)

		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		testerDC:Do("SendData", {Data = data} )

		-- Read the result from the buffer
		local result = testeeDC:Do("ReadData")


		--Verify that data transmitted is the same as data received.
		CheckEqual(data, result.Data)
	end
	},

	TestCase "Transmit"
	{
	function()

		testerCommandSettings, testeeCommandSettings,
		testerUserSettings, testeeUserSettings = getDefaultSettings()
		--Changes occur here
		testerUserSettings.ChimeraCan.IP = "10.1.1.3"
		testerUserSettings.ChimeraCan.CanPort = "HighSpeed"
		testeeUserSettings.ChimeraCan.CanPort = "HighSpeed"

		testerCommandSettings.CAN.Transceiver = 1
		testeeCommandSettings.CAN.Transceiver = 1

		setModifiedSettings("ChimeraCan",
							testerCommandSettings, testeeCommandSettings,
							testerUserSettings, testeeUserSettings)
		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		testeeDC:Do("SendData", {Data = data} )

		-- Read the result from the buffer
		local result = testerDC:Do("ReadData")


		--Verify that data transmitted is the same as data received.
		CheckEqual(data, result.Data)
	end
	},

	EachTeardown = function()
		testerDC:Shutdown()
		testeeDC:Shutdown()
	end,

	Teardown = function()
	end,
}
--]=]

--[ =[Muxed CAN
--[[ Verify Muxed Can transcievers
 This test suite transmits and receives data using the CAN2 port.
 Note that this test suite moves Setup into the test cases and
 teardown into the EachTeardown functions.
--]]
TestSuite "ChimeraCanMuxed"
{
	Setup = function()
	end,


	EachSetup = function()
	end,

	TestCase "ReceiveLS"
	{
	function()
		testerCommandSettings, testeeCommandSettings,
		testerUserSettings, testeeUserSettings = getDefaultSettings()

		testerUserSettings.ChimeraCan.IP = "10.1.1.3"
		--LS transciever is default
		setModifiedSettings("ChimeraCan",
							testerCommandSettings, testeeCommandSettings,
							testerUserSettings, testeeUserSettings)

		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		testerDC:Do("SendData", {Data = data} )

		-- Read the result from the buffer
		local result = testeeDC:Do("ReadData")


		--Verify that data transmitted is the same as data received.
		CheckEqual(data, result.Data)
	end
	},

	TestCase "TransmitLS"
	{
	function()
		testerCommandSettings, testeeCommandSettings,
		testerUserSettings, testeeUserSettings = getDefaultSettings()

		testerUserSettings.ChimeraCan.IP = "10.1.1.3"

		setModifiedSettings("ChimeraCan",
							testerCommandSettings, testeeCommandSettings,
							testerUserSettings, testeeUserSettings)

		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		testeeDC:Do("SendData", {Data = data} )

		-- Read the result from the buffer
		local result = testerDC:Do("ReadData")


		--Verify that data transmitted is the same as data received.
		CheckEqual(data, result.Data)
	end
	},

	TestCase "ReceiveHS"
	{

	function()
		testerCommandSettings, testeeCommandSettings,
		testerUserSettings, testeeUserSettings = getDefaultSettings()

		testerUserSettings.ChimeraCan.IP = "10.1.1.3"

		testerUserSettings.ChimeraCan.Transciever = 1
		testerUserSettings.ChimeraCan.Transciever = 1
		setModifiedSettings("ChimeraCan",
							testerCommandSettings, testeeCommandSettings,
							testerUserSettings, testeeUserSettings)

		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		testerDC:Do("SendData", {Data = data} )

		-- Read the result from the buffer
		local result = testeeDC:Do("ReadData")


		--Verify that data transmitted is the same as data received.
		CheckEqual(data, result.Data)
	end
	},

	TestCase "TransmitHS"
	{
	function()

		testerCommandSettings, testeeCommandSettings,
		testerUserSettings, testeeUserSettings = getDefaultSettings()

		testerUserSettings.ChimeraCan.IP = "10.1.1.3"

		testerUserSettings.ChimeraCan.Transciever = 1
		testerUserSettings.ChimeraCan.Transciever = 1
		setModifiedSettings("ChimeraCan",
							testerCommandSettings, testeeCommandSettings,
							testerUserSettings, testeeUserSettings)
		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		testeeDC:Do("SendData", {Data = data} )

		-- Read the result from the buffer
		local result = testerDC:Do("ReadData")


		--Verify that data transmitted is the same as data received.
		CheckEqual(data, result.Data)
	end
	},

	TestCase "ReceiveSW"
	{
	function()
		testerCommandSettings, testeeCommandSettings,
		testerUserSettings, testeeUserSettings = getDefaultSettings()

		testerUserSettings.ChimeraCan.IP = "10.1.1.3"

		testerUserSettings.ChimeraCan.Transciever = 2
		testerUserSettings.ChimeraCan.Transciever = 2
		setModifiedSettings("ChimeraCan",
							testerCommandSettings, testeeCommandSettings,
							testerUserSettings, testeeUserSettings)
		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		testerDC:Do("SendData", {Data = data} )

		-- Read the result from the buffer
		local result = testeeDC:Do("ReadData")


		--Verify that data transmitted is the same as data received.
		CheckEqual(data, result.Data)
	end
	},

	TestCase "TransmitSW"
	{
	function()
		testerCommandSettings, testeeCommandSettings,
		testerUserSettings, testeeUserSettings = getDefaultSettings()

		testerUserSettings.ChimeraCan.IP = "10.1.1.3"

		testerUserSettings.ChimeraCan.Transciever = 2
		testerUserSettings.ChimeraCan.Transciever = 2
		setModifiedSettings("ChimeraCan",
							testerCommandSettings, testeeCommandSettings,
							testerUserSettings, testeeUserSettings)

		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		testeeDC:Do("SendData", {Data = data} )

		-- Read the result from the buffer
		local result = testerDC:Do("ReadData")


		--Verify that data transmitted is the same as data received.
		CheckEqual(data, result.Data)
	end
	},
	EachTeardown = function()
		testerDC:Shutdown()
		testeeDC:Shutdown()
	end,

	Teardown = function()

	end,
}
--]=]

--[=[XXXChimeraI2C: Times out waiting for Ack. This is because the Chimera isn't meant to be a slave I2C node, only a listener/master.
-- Error: Timeout waiting for Ack to 0xAA BB CC  id=0x000, Decoded, 29bit, TxData (MissingAckEx: .\ResourceManagerClient.pp@181)
--[[ Verify ChimeraI2C
 This test suite transmits and receives data using the I2C port.
--]]
TestSuite "ChimeraI2C"
{
}
--]=]

--[ =[ChimeraLin
--[BUG] Error: LIN Slave did not respond. | Do( ReadData )  < Happened once in about thirty tries
--[[ Verify ChimeraLin
 This test suite transmits and receives data using the LIN port.
--]]
TestSuite "ChimeraLin"
{
	Setup = function()
	end,

	EachSetup = function()
	end,

	TestCase "Transmit"
	{
	function()
		testerCommandSettings, testeeCommandSettings,
		testerUserSettings, testeeUserSettings = getDefaultSettings()
		--Changes occur here
		testerUserSettings.ChimeraLin.IP = "10.1.1.3"

		--TODO: Configure one as slave, one as master?


		testerCommandSettings.LIN.PadToFrameSize = 1
		testeeCommandSettings.LIN.PadToFrameSize = 1

		setModifiedSettings("ChimeraLin",
							testerCommandSettings, testeeCommandSettings,
							testerUserSettings, testeeUserSettings)

		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC, 0xEE};
		testeeDC:Do("SendData", {Data = data} )

		sleep(0.1)

		-- Read the result from the buffer
		local result = testerDC:Do("ReadData")

		--Verify that data transmitted is the same as data received.
		CheckEqual(data, result.Data)
	end
	},

	TestCase "Receive"
	{
	function()
		testerCommandSettings, testeeCommandSettings,
		testerUserSettings, testeeUserSettings = getDefaultSettings()
		--Changes occur here
		testerUserSettings.ChimeraLin.IP = "10.1.1.3"

		--TODO: Configure one as slave, one as master?

		setModifiedSettings("ChimeraLin",
							testerCommandSettings, testeeCommandSettings,
							testerUserSettings, testeeUserSettings)

		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC, 0xDD};
		testerDC:Do("SendData", {Data = data} )

		sleep(0.1)

		-- Read the result from the buffer
		local result = testeeDC:Do("ReadData")

		--Verify that data transmitted is the same as data received.
		CheckEqual(data, result.Data)
	end
	},

	EachTeardown = function()
		testerDC:Shutdown()
		testeeDC:Shutdown()
	end,

	Teardown = function()
	end,
}
--]=]


--[=[XChimeraRevComm: Causes Chimera to be nonresponsive, needing hard reset: Wait for bug fix.
-- Last info in ChimeraDebug: Address Error at 0x00010910
--[[ Verify ChimeraRevComm
 This test suite transmits and receives data using the RevComm port.
--]]
TestSuite "ChimeraRevComm"
{
	Setup = function()
		--Create DeviceComm objects with command settings
		testerDC = DeviceComm.new( CommandSetPath )
		testeeDC = DeviceComm.new( CommandSetPath )

		--Set up tester for defaults
		local testerCommandSettings = DefaultCommandSettings
		local testeeCommandSettings = DefaultCommandSettings

		--Changes occur here

		--Assign to DeviceComm objects
		testerDC:SetProtocolSettings("Commands", testerCommandSettings)
		testeeDC:SetProtocolSettings("Commands", testeeCommandSettings)

		--Initialize DeviceComm objects with user settings
		--Create tables from default
		local testerUserSettings = tcopy(DefaultUserSettings)
		local testeeUserSettings = tcopy(DefaultUserSettings)

		--Changes occur here
		testerUserSettings.ChimeraRevComm.IP = "10.1.1.3"

		--Assign to DeviceComm objects
		testerDC:Initialize("ChimeraRevComm", testerUserSettings.ChimeraRevComm)
		testeeDC:Initialize("ChimeraRevComm", testeeUserSettings.ChimeraRevComm)
	end,


	EachSetup = function()
	end,

	TestCase "Transmit"
	{
	function()
		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		testeeDC:Do("SendData", {Data = data} )

		sleep(0.1)


		-- Read the result from the buffer
		local result = testerDC:Do("ReadData")


		--Verify that data transmitted is the same as data received.
		CheckEqual(data, result.Data)
	end
	},

	TestCase "Receive"
	{
	function()
		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		testerDC:Do("SendData", {Data = data} )

		sleep(0.1)

		-- Read the result from the buffer
		local result = testeeDC:Do("ReadData")

		--Verify that data transmitted is the same as data received.
		CheckEqual(data, result.Data)
	end
	},

	EachTeardown = function()
	end,

	Teardown = function()
		testerDC:Shutdown()
		testeeDC:Shutdown()
	end,
}
--]=]

--[=[XXXChimeraSDL: Does not support SDL transmission.
--[[ Verify ChimeraSDL
 This test suite transmits and receives data using the SDL port.
--]]
TestSuite "ChimeraSDL"
{

}
--]=]

--[ =[ChimeraSerial
--[[ Verify ChimeraSerial
 This test suite transmits and receives data using the Serial port.
--]]
TestSuite "ChimeraSerial"
{
	Setup = function()
		--Declare a send receive array function for the serial case, which reads byte by byte.
		function SendReceiveSerialArray(senderDC, receiverDC, arr)
			senderDC:Do("SendData", {Data = arr} )

			local out = {}
			for i,v in ipairs(arr) do
				result = receiverDC:Do("ReadData")
				CheckEqual(v, result.Data[1])
			end
		end
	end,


	EachSetup = function()
	end,

	TestCase "RS232_Receive"
	{
	function()
		testerCommandSettings, testeeCommandSettings,
		testerUserSettings, testeeUserSettings = getDefaultSettings()

		testerUserSettings.ChimeraSerial.IP = "10.1.1.3"
		--RS232 is the default.

		setModifiedSettings("ChimeraSerial",
							testerCommandSettings, testeeCommandSettings,
							testerUserSettings, testeeUserSettings)

		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		SendReceiveSerialArray(testerDC, testeeDC, data)

	end
	},

	TestCase "RS232_Transmit"
	{
	function()
		testerCommandSettings, testeeCommandSettings,
		testerUserSettings, testeeUserSettings = getDefaultSettings()

		testerUserSettings.ChimeraSerial.IP = "10.1.1.3"
		--RS232 is the default.

		setModifiedSettings("ChimeraSerial",
							testerCommandSettings, testeeCommandSettings,
							testerUserSettings, testeeUserSettings)

		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		SendReceiveSerialArray(testeeDC, testerDC, data)
	end
	},

		TestCase "RS485_Receive"
	{
	function()
		testerCommandSettings, testeeCommandSettings,
		testerUserSettings, testeeUserSettings = getDefaultSettings()

		testerUserSettings.ChimeraSerial.IP = "10.1.1.3"
		testerUserSettings.ChimeraSerial.Mode = "RS485"
		testeeUserSettings.ChimeraSerial.Mode = "RS485"

		setModifiedSettings("ChimeraSerial",
							testerCommandSettings, testeeCommandSettings,
							testerUserSettings, testeeUserSettings)

		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		SendReceiveSerialArray(testerDC, testeeDC, data)

	end
	},

	TestCase "RS485_Transmit"
	{
	function()
		testerCommandSettings, testeeCommandSettings,
		testerUserSettings, testeeUserSettings = getDefaultSettings()

		testerUserSettings.ChimeraSerial.IP = "10.1.1.3"
		testerUserSettings.ChimeraSerial.Mode = "RS485"
		testeeUserSettings.ChimeraSerial.Mode = "RS485"

		setModifiedSettings("ChimeraSerial",
							testerCommandSettings, testeeCommandSettings,
							testerUserSettings, testeeUserSettings)

		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		SendReceiveSerialArray(testeeDC, testerDC, data)
	end
	},

	EachTeardown = function()
	end,

	Teardown = function()
		SendReceiveSerialArray = nil;
		testerDC:Shutdown()
		testeeDC:Shutdown()
	end,
}
--]=]
