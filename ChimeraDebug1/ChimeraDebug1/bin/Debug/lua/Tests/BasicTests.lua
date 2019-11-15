require("Chronos")

dofile("LoadLibs.lua")

--[[These test suites exercise the hardware of the Chimera under test
	in order to debug why the chimera isn't working or to see if it is
	a good chimera. While the tests ran don't show exactly what is wrong,
	they will point to an area that isn't working. Then, using a schematic
	as a tool, along with this test as a guide, one can debug and repair
	the bad chimera.
--]]

--[[NOTES:

	-IP Address
		*Tester IP = 10.1.1.3
		*DUT IP    = 10.1.1.2

		These are what the IP addresses must be for the designated chimera boards

	-ChimeraCAN
		*Must connect to DUT using ChimeraCAN before I2C test
		*Must perform Dallas test before connecting to DUT using ChimeraCAN

		For I2C test to work, must have connected at any point to DUT chimera using ChimeraCAN
		before running test. Else, no devices will be detected when running I2C test. With that,
		the Dallas test is just the opposite. Dallas test will not detect any devices if
		ChimeraCAN is used to connect to DUT chimera at any point before the test is ran.

	-ChimeraLIN
		*Using ChimeraLIN to connect to DUT for V_IGN, V_BAT, and V_REV test caused
		each line to remain at ~10V regardless of telling it to change state (ON/OFF or OpenComm for V_REV)
--]]


--[[ Dallas
--]]
TestSuite "Dallas"
{
	Setup = function()
		inc()
		comment("Basic.\n", 0)
		inc()
	end,

	TestCase "Check Dallas"
	{
	function()
		--Establish DUT connection to allow use of "GetDallasRoms" DEVIO function
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

		setModifiedSettings("ChimeraDallas",
						testerCommandSettings, DUTCommandSettings,
						testerUserSettings, DUTUserSettings)



				AddComment("NOTE: See README.doc for the following errors")
				AddComment("Error: didn’t detect any devices")
				AddComment("Error: Chimera did not respond. Is it connected?")
				AddComment("\n\n\n")

			--Read dallas ID from EEPROM
			local ID = DUTDC:Do("GetDallasRoms").rom_0
				AddComment("Dallas ID:  "..ID)
				AddComment("\n")

		--ReConnect DUT using correct dallas ID
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

			DUTUserSettings.ChimeraDallas["Dallas Id"] = ID

		setModifiedSettings("ChimeraDallas",
						testerCommandSettings, DUTCommandSettings,
						testerUserSettings, DUTUserSettings)



			--location and data to write/read
			--Does not matter what or where so long as it exists within the parameters of the Dallas Chip
			local offset = 0x00
			local address =	0x05
			local dataWrite = 0xCB



		--Write to Scratchpad
		DUTDC:Do("Write_Scratchpad", {TA1=offset,TA2=address,data=dataWrite})
			AddComment(dataWrite.." written to address: "..address.."   with offset: "..offset)
			AddComment("\n")

		--Read back from Scratchpad what was just written
		local dataRead = DUTDC:Do("Read_Scratchpad").data[1]
			AddComment(dataRead.." read from address: "..address.."   with offset: "..offset)
			AddComment("\n")


		--verify data written is same as data returned for test Pass/Fail
		CheckEqual(dataWrite, dataRead)
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
--[[ 1W1 / 1W2
--]]
--*******************************************************************************************Single Wire 1************************************************************************
--********************************************************************************************************************************************************************************
TestSuite "SingleWire1"
{
	Setup = function()
		inc()
		comment("Basic.\n", 0)
		inc()
	end,

	TestCase "Check Pullup Resistors"
	{
	function()
		--Initialize tester Lin communication outside of loop
		testerDC = DeviceComm.new( CommandSetPath )

		testerUserSettings = tcopy(DefaultUserSettings)

			--changes from default
			testerUserSettings.ChimeraLin.IP = "10.1.1.3"
			testerUserSettings.ChimeraLin.LinPort = "LIN1"
			testerUserSettings.ChimeraLin.PullupSelection = "Open" 	--set tester resistor select to open to cut off the tester 1wire1 line from the DUT
																	--Having it anything but open creates a parallel resistance with the DUT, causing a false read
		testerDC:Initialize("ChimeraLin", testerUserSettings["ChimeraLin"])



			local Rdivide = 8442      	-- 10K in parallel with 54.2k (44.2K + 10K) for ADC read from chimera schematic
			local Vunreg = 14.86		-- measured voltage for Vunreg
			local VdivideGain = 5.42  	-- gain from ADC1WIRE1 on micro to 1WIRE1 from J6 Connector due to voltage divider
			local ADCGain = 0.97073   	-- ADC Gain and Offset are to make up for an uncalibrated ADC on the chimera for closer accuracy
			local ADCoffset = 144.16
			local tolerance = 0.10  	-- desired tolerance for calculated resistor values

			local errorMessage = ""
			local sum = true
			local Tolcheck = true
			local Voltage = {}

			local PullupSelectTable = {	"Open", --possible revcomm pullup resistor selections on chimera
										"1.5k",	--string is needed for setting up chimera communication
										"2.2k",
										"6.8k",
										"10k",	}
			local ResistorValueTable = {0,		--same as pullup select table but numbers rather than string
										1.5,
										2.2,
										6.8,
										10,	}



				--switching ON tester collector OCC1 to isolate DUT 1wire1 from tester
				testerDC:Write("OpenCollectors", { Value = 0x01, Mask = 0x0F })
				AddComment("DUT 1Wire1 disconnected from tester 1Wire1")
				AddComment("\n")

				--using tester GPIO RE(0,1,2) to select DUT 1wire1 to connect 10k pulldown
				testerDC:Write("GPIO", { Value = 0x06, Mask = 0xFF, Direction = 0x00 })
				AddComment("10K pulldown resistor connected to DUT 1Wire1")


						--[[ Tester GPIO table for selecting pulldown resistors

								write the following values using the tester chimera GPIO
								to select the following resistor on the given line. The
								pulldown resistors are connected to a mux and selected
								by the Tester GPIO REout pins.


								Write		Wire
								value		Selection		Resistance
							----------------------------------------------
								0x00		none			none
								0x04		1Wire 1			1k
								0x06		1Wire 1			10k
								0x07		1Wire 2			1k
								0x05		1Wire 2			10k
						--]]



		--loop to cycle through all DUT pullup resistors
		for i= 1, 5 do

			--initialize DUT connection with different pullup each loop
			DUTDC = DeviceComm.new( CommandSetPath )

			DUTUserSettings = tcopy(DefaultUserSettings)

				DUTUserSettings.ChimeraLin.LinPort = "LIN1"
				DUTUserSettings.ChimeraLin.PullupSelection = PullupSelectTable[i]

			DUTDC:Initialize("ChimeraLin", DUTUserSettings["ChimeraLin"])



					--formatting and printing selected pullup resistor
					AddComment("\n")

					if PullupSelectTable[i] == "Open" then
						AddComment("Pullup selected:  "..PullupSelectTable[i])

					else
						AddComment("Pullup selected:  "..PullupSelectTable[i])

					end



			--reading ADC1WIRE1 from DUT Micro
			Voltage[PullupSelectTable[i] ] = DUTDC:Read("Analog").SingleWire1 * VdivideGain

			--Voltage Divider  R1 = R2*(Vin-Vout)/Vout
			local Rpullup = ((((( Rdivide *( Vunreg - Voltage[PullupSelectTable[i] ] ))/ Voltage[PullupSelectTable[i] ]) * ADCGain) - ADCoffset) * .001)



					--formatting and printing chimera test results
					if PullupSelectTable[i] == "Open" then
						Voltage[PullupSelectTable[i] ] = string.format("%.2f",Voltage[PullupSelectTable[i] ])
						AddComment("SingleWire1 Voltage:  "..Voltage[PullupSelectTable[i] ].."v")

					else
						Voltage[PullupSelectTable[i] ] = string.format("%.2f",Voltage[PullupSelectTable[i] ])
						AddComment("SingleWire1 Voltage:  "..Voltage[PullupSelectTable[i] ].."v")

						Rpullup = tonumber(string.format("%.2f",Rpullup))
						AddComment("Calculated Resistance:  "..Rpullup.."k")
					end



			--checking calculated resistor value is within +/- X % of expected
			--calculated value will not be perfect since ADC is not calibrated with each loop
			local low = ResistorValueTable[i] - ( ResistorValueTable[i] * tolerance )
			local high = ResistorValueTable[i] + ( ResistorValueTable[i] * tolerance )



					--any check failing puts final check false
					--keeps track of error message in case of fail
					if
						(( Rpullup >= low ) and ( Rpullup <= high ))
						then Tolcheck = true

					elseif
						tonumber(Voltage[PullupSelectTable[i] ]) == 0
						then Tolcheck = true

					else
						Tolcheck = false
					end

						--keeping track of pass or fail with each loop
						sum = (sum and Tolcheck)

					--adds to error message with each corresponding fail
					if not Tolcheck then
						errorMessage = errorMessage..PullupSelectTable[i].." pullup selection out of "..(tolerance*100).."% tolerance range! Check calculated resistor value!\n"
					end

		end


			AddComment("\n") --print formatting

			--Reseting open collectors and GPIO
			testerDC:Write("OpenCollectors", { Value = 0x00, Mask = 0x0F })
			testerDC:Write("GPIO", { Value = 0x00, Mask = 0xFF, Direction = 0x00 })

		Check(sum,errorMessage)
	end
	},

	TestCase "Check RevComm Transmission"
	{
	function()
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

			--Changes from default occur here
			testerUserSettings.ChimeraLin.IP = "10.1.1.3"

			testerUserSettings.ChimeraLin.LinPort = "LIN1"
			DUTUserSettings.ChimeraLin.LinPort = "LIN1"

		--	testerCommandSettings.LIN.PadToFrameSize = 1
		--	DUTCommandSettings.LIN.PadToFrameSize = 1

		setModifiedSettings("ChimeraLin",
							testerCommandSettings, DUTCommandSettings,
							testerUserSettings, DUTUserSettings)

					AddComment("NOTE: See README.doc for the following error")
					AddComment("Error: Message was empty!")
					AddComment("\n\n\n")


				--Switch on OCC3 to turn on relay and short 1W1 between tester and DUT
				testerDC:Write("OpenCollectors", { Value = 0x04, Mask = 0x0F })



		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC, 0xDD};
		DUTDC:Do("SendData", {Data = data} )

		-- Read the result from the buffer
		local result = testerDC:Do("ReadData")



				--Switch off all open collectors
				testerDC:Write("OpenCollectors", { Value = 0x00, Mask = 0x0F })



		--Verify that data transmitted is the same as data received.
		CheckEqual(data, result.Data)
	end
	},

	TestCase "Check RevComm Reception"
	{
	function()
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

			--Changes from default occur here
			testerUserSettings.ChimeraLin.IP = "10.1.1.3"

			testerUserSettings.ChimeraLin.LinPort = "LIN1"
			DUTUserSettings.ChimeraLin.LinPort = "LIN1"

		--	testerCommandSettings.LIN.PadToFrameSize = 1
		--	DUTCommandSettings.LIN.PadToFrameSize = 1

		setModifiedSettings("ChimeraLin",
							testerCommandSettings, DUTCommandSettings,
							testerUserSettings, DUTUserSettings)



				--Switch on OCC3 to turn on relay and short 1W1 between tester and DUT
				testerDC:Write("OpenCollectors", { Value = 0x04, Mask = 0x0F })



		-- Send data
		local data   = {0xAA, 0xBB, 0xCC, 0xEE};
		testerDC:Do("SendData", {Data = data} )

		-- Read the result from the buffer
		local result = DUTDC:Do("ReadData")



				--Switch off all open collectors
				testerDC:Write("OpenCollectors", { Value = 0x00, Mask = 0x0F })



		--Verify that data transmitted is the same as data received.
		CheckEqual(data, result.Data)
	end
	},

	EachTeardown = function()
		--Align Pass/Fail/Pending message with comments
		io.write("\n", string.rep(" ", indent))
	end,

	Teardown = function()
		dec()
		--comment("End of test suite.", 0)
		dec()
	end,
}
--*******************************************************************************************Single Wire 2************************************************************************
--********************************************************************************************************************************************************************************
TestSuite "SingleWire2"
{
	Setup = function()
		inc()
		comment("Basic.\n", 0)
		inc()
	end,

	TestCase "Check LIN Transmission"
	{
	function()
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

			--Changes from default occur here
			--tester using 1wire1 (LIN1)
			--DUT using 1wire2 (LIN2)
			testerUserSettings.ChimeraLin.IP = "10.1.1.3"

			testerUserSettings.ChimeraLin.LinPort = "LIN1"
			DUTUserSettings.ChimeraLin.LinPort = "LIN2"

		--	testerCommandSettings.LIN.PadToFrameSize = 1
		--	DUTCommandSettings.LIN.PadToFrameSize = 1

		setModifiedSettings("ChimeraLin",
							testerCommandSettings, DUTCommandSettings,
							testerUserSettings, DUTUserSettings)



					AddComment("NOTE: See README.doc for the following error")
					AddComment("Error: Message was empty!")
					AddComment("\n\n\n")



				--Switch on OC1, OC2 to turn on relay and short 1W2 between tester and DUT
				testerDC:Write("OpenCollectors", { Value = 0x03, Mask = 0x0F })



		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC, 0xEE};
		DUTDC:Do("SendData", {Data = data} )

		-- Read the result from the buffer
		local result = testerDC:Do("ReadData")



				--Switch off all open collectors
				testerDC:Write("OpenCollectors", { Value = 0x00, Mask = 0x0F })



		--Verify that data transmitted is the same as data received.
		CheckEqual(data, result.Data)
	end
	},

	TestCase "Check LIN Reception"
	{
	function()
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

			--Changes occur here
			--tester using 1wire1 (LIN1)
			--DUT using 1wire2 (LIN2)
			testerUserSettings.ChimeraLin.IP = "10.1.1.3"

			testerUserSettings.ChimeraLin.LinPort = "LIN1"

		--	testerCommandSettings.LIN.PadToFrameSize = 1
		--	DUTCommandSettings.LIN.PadToFrameSize = 1

		setModifiedSettings("ChimeraLin",
							testerCommandSettings, DUTCommandSettings,
							testerUserSettings, DUTUserSettings)



				--Switch on OCC1, OCC2 to turn on relay and short 1W2 between tester and DUT
				testerDC:Write("OpenCollectors", { Value = 0x03, Mask = 0x0F })



		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC, 0xDD};
		testerDC:Do("SendData", {Data = data} )

		-- Read the result from the buffer
		local result = DUTDC:Do("ReadData")



				--Switch off all open collectors
				testerDC:Write("OpenCollectors", { Value = 0x00, Mask = 0x0F })



		--Verify that data transmitted is the same as data received.
		CheckEqual(data, result.Data)
	end
	},

	EachTeardown = function()
		testerDC:Shutdown()
		DUTDC:Shutdown()
		--Align Pass/Fail/Pending message with comments
		io.write("\n", string.rep(" ", indent))
	end,

	Teardown = function()
		dec()
		--comment("End of test suite.", 0)
		dec()
	end,
}
--]]
--[[ UART
--]]
--*******************************************************************************************UART*********************************************************************************
--********************************************************************************************************************************************************************************
TestSuite "UART protocols"
{
	Setup = function()
		inc()
		comment("Basic.\n", 0)
		inc()
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

	TestCase "Check RS232 Reception"
	{
	function()
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

			testerUserSettings.ChimeraSerial.IP = "10.1.1.3"
			--RS232 is the default.

		setModifiedSettings("ChimeraSerial",
							testerCommandSettings, DUTCommandSettings,
							testerUserSettings, DUTUserSettings)



		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		SendReceiveSerialArray(testerDC, DUTDC, data)
	end
	},

	TestCase "Check RS232 Transmission"
	{
	function()
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

			testerUserSettings.ChimeraSerial.IP = "10.1.1.3"
			--RS232 is the default.

		setModifiedSettings("ChimeraSerial",
							testerCommandSettings, DUTCommandSettings,
							testerUserSettings, DUTUserSettings)



		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		SendReceiveSerialArray(DUTDC, testerDC, data)
	end
	},

		TestCase "Check RS485 Reception"
	{
	function()
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

			testerUserSettings.ChimeraSerial.IP = "10.1.1.3"
			testerUserSettings.ChimeraSerial.Mode = "RS485"
			DUTUserSettings.ChimeraSerial.Mode = "RS485"

		setModifiedSettings("ChimeraSerial",
							testerCommandSettings, DUTCommandSettings,
							testerUserSettings, DUTUserSettings)



		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		SendReceiveSerialArray(testerDC, DUTDC, data)
	end
	},

	TestCase "Check RS485 Transmission"
	{
	function()
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

			testerUserSettings.ChimeraSerial.IP = "10.1.1.3"
			testerUserSettings.ChimeraSerial.Mode = "RS485"
			DUTUserSettings.ChimeraSerial.Mode = "RS485"

		setModifiedSettings("ChimeraSerial",
							testerCommandSettings, DUTCommandSettings,
							testerUserSettings, DUTUserSettings)



		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		SendReceiveSerialArray(DUTDC, testerDC, data)
	end
	},
	--Can't test SDL without broadcast ability

	TestCase "Check RS422 Transmission"
	{
	function()
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

			testerUserSettings.ChimeraSerial.IP = "10.1.1.3"
			testerUserSettings.ChimeraSerial.Mode = "RS485"
			DUTUserSettings.ChimeraSerial.Mode = "RS422"

		setModifiedSettings("ChimeraSerial",
							testerCommandSettings, DUTCommandSettings,
							testerUserSettings, DUTUserSettings)



		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		SendReceiveSerialArray(DUTDC, testerDC, data)
	end
	},

	EachTeardown = function()
		testerDC:Shutdown()
		DUTDC:Shutdown()
		--Align Pass/Fail/Pending message with comments
		io.write("\n", string.rep(" ", indent))
	end,

	Teardown = function()
		dec()
		--comment("End of test suite.", 0)
		dec()
		SendReceiveSerialArray = nil;
	end,
}
--]]
--[[ CAN Tests
--]]
--*********************************************************************************Dedicated High Speed CAN*****************************************************************
--**************************************************************************************************************************************************************************
TestSuite "Dedicated High Speed CAN"
{

	Setup = function()
		inc()
		comment("Basic.\n", 0)
		inc()
	end,

	TestCase "Check Transmission"
	{
	function()
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

			--Changes from default occur here
			testerUserSettings.ChimeraCan.IP = "10.1.1.3"
			testerUserSettings.ChimeraCan.CanPort = "HighSpeed"
			DUTUserSettings.ChimeraCan.CanPort = "HighSpeed"

			testerCommandSettings.CAN.Transceiver = 1
			DUTCommandSettings.CAN.Transceiver = 1

		setModifiedSettings("ChimeraCan",
							testerCommandSettings, DUTCommandSettings,
							testerUserSettings, DUTUserSettings)



		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		DUTDC:Do("SendData", {Data = data} )

		-- Read the result from the buffer
		local result = testerDC:Do("ReadData")



		--Verify that data transmitted is the same as data received.
		CheckEqual(data, result.Data)
	end
	},

	TestCase "Check Reception"
	{
	function()
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

			--Changes from default occur here
			testerCommandSettings.CAN.Transceiver = 1
			DUTCommandSettings.CAN.Transceiver = 1

			testerUserSettings.ChimeraCan.IP = "10.1.1.3"

			testerUserSettings.ChimeraCan.CanPort = "HighSpeed"
			DUTUserSettings.ChimeraCan.CanPort = "HighSpeed"

		setModifiedSettings("ChimeraCan",
							testerCommandSettings, DUTCommandSettings,
							testerUserSettings, DUTUserSettings)



		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		testerDC:Do("SendData", {Data = data} )

		-- Read the result from the buffer
		local result = DUTDC:Do("ReadData")



		--Verify that data transmitted is the same as data received.
		CheckEqual(data, result.Data)
	end
	},


	EachTeardown = function()
		testerDC:Shutdown()
		DUTDC:Shutdown()
		--Align Pass/Fail/Pending message with comments
		io.write("\n", string.rep(" ", indent))
	end,

	Teardown = function()
		dec()
		--comment("End of test suite.", 0)
		dec()
	end,
}
--************************************************************************************Multiplexed CAN***************************************************************************
--******************************************************************************************************************************************************************************
TestSuite "Multiplexed CAN"
{
	Setup = function()
		inc()
		comment("Basic.\n", 0)
		inc()
	end,

	TestCase "Check Low Speed Reception"
	{
	function()
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

			testerUserSettings.ChimeraCan.IP = "10.1.1.3"
			--LS transciever is default

		setModifiedSettings("ChimeraCan",
							testerCommandSettings, DUTCommandSettings,
							testerUserSettings, DUTUserSettings)



		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		testerDC:Do("SendData", {Data = data} )

		-- Read the result from the buffer
		local result = DUTDC:Do("ReadData")



		--Verify that data transmitted is the same as data received.
		CheckEqual(data, result.Data)
	end
	},

	TestCase "Check Low Speed Transmission"
	{
	function()
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

			testerUserSettings.ChimeraCan.IP = "10.1.1.3"

		setModifiedSettings("ChimeraCan",
							testerCommandSettings, DUTCommandSettings,
							testerUserSettings, DUTUserSettings)



		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		DUTDC:Do("SendData", {Data = data} )

		-- Read the result from the buffer
		local result = testerDC:Do("ReadData")



		--Verify that data transmitted is the same as data received.
		CheckEqual(data, result.Data)
	end
	},

	TestCase "Check High Speed Reception"
	{

	function()
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

			testerUserSettings.ChimeraCan.IP = "10.1.1.3"

			--Select High Speed transciever
			testerUserSettings.ChimeraCan.Transciever = 1
			testerUserSettings.ChimeraCan.Transciever = 1

		setModifiedSettings("ChimeraCan",
							testerCommandSettings, DUTCommandSettings,
							testerUserSettings, DUTUserSettings)



		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		testerDC:Do("SendData", {Data = data} )

		-- Read the result from the buffer
		local result = DUTDC:Do("ReadData")



		--Verify that data transmitted is the same as data received.
		CheckEqual(data, result.Data)
	end
	},

	TestCase "Check High Speed Transmission"
	{
	function()
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

			testerUserSettings.ChimeraCan.IP = "10.1.1.3"

			--Select High Speed transciever
			testerUserSettings.ChimeraCan.Transciever = 1
			testerUserSettings.ChimeraCan.Transciever = 1

		setModifiedSettings("ChimeraCan",
							testerCommandSettings, DUTCommandSettings,
							testerUserSettings, DUTUserSettings)


		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		DUTDC:Do("SendData", {Data = data} )

		-- Read the result from the buffer
		local result = testerDC:Do("ReadData")



		--Verify that data transmitted is the same as data received.
		CheckEqual(data, result.Data)
	end
	},

	TestCase "Check Singlewire Reception"
	{
	function()
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

			testerUserSettings.ChimeraCan.IP = "10.1.1.3"

			testerUserSettings.ChimeraCan.Transciever = 2
			testerUserSettings.ChimeraCan.Transciever = 2

		setModifiedSettings("ChimeraCan",
							testerCommandSettings, DUTCommandSettings,
							testerUserSettings, DUTUserSettings)


		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		testerDC:Do("SendData", {Data = data} )

		-- Read the result from the buffer
		local result = DUTDC:Do("ReadData")



		--Verify that data transmitted is the same as data received.
		CheckEqual(data, result.Data)
	end
	},

	TestCase "Check Singlewire Transmission"
	{
	function()
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

			--changes from default occur here
			testerUserSettings.ChimeraCan.IP = "10.1.1.3"

			testerUserSettings.ChimeraCan.Transciever = 2
			testerUserSettings.ChimeraCan.Transciever = 2

		setModifiedSettings("ChimeraCan",
							testerCommandSettings, DUTCommandSettings,
							testerUserSettings, DUTUserSettings)



		-- Send data
		local data   = { 0xAA, 0xBB, 0xCC};
		DUTDC:Do("SendData", {Data = data} )

		-- Read the result from the buffer
		local result = testerDC:Do("ReadData")



		--Verify that data transmitted is the same as data received.
		CheckEqual(data, result.Data)
	end
	},
-- Does this need to go here?
--	TestCase "Check Unmuxed CAN2 Lines"
--	{
--	function()
--		Pending()
--		comment("Test C1W, CANMOD, HS CAN, LS CAN, SW CAN on 34-pin (unmuxed)")
--	end
--	},
--
	EachTeardown = function()
		testerDC:Shutdown()
		DUTDC:Shutdown()

		--Align Pass/Fail/Pending message with comments
		io.write("\n", string.rep(" ", indent))
	end,

	Teardown = function()
		dec()
		--comment("End of test suite.", 0)
		dec()
	end,

}
--]]
--[[ Aux IO
--]]
--*******************************************************************************************AUX IO*******************************************************************************
--********************************************************************************************************************************************************************************
TestSuite "Aux IO"
{
	Setup = function()
		inc()
		comment("Basic.\n", 0)
		inc()
	end,

	TestCase "Check Switches"
	{
	function()
		Pending()
		comment("Test switches after exposing functionality (feat. 1601)")
		AddComment("Switch functionality not currently supported by chimera firmware")

	end
	},

	TestCase "Check LEDs"
	{
	function()

		--Initialize devicecomm objects with associated devIO commandset file
		DUTDC = DeviceComm.new( CommandSetPath )

		--Get default settings for the communication protocols
		DUTUserSettings = tcopy(DefaultUserSettings)

		--Initialize CAN communication
		DUTDC:Initialize("ChimeraCan", DUTUserSettings["ChimeraCan"])


			--GPIO values to write for each given diode
			local D5     = 0x01
			local D15    = 0x02
			local D14    = 0x04
			local D16    = 0x08
			local Mask   = 0x0F
			local allLED = 0x0F

			local LEDcheck = true
			local fMessage = "Failed LED/s :  "
			local evalLEDPF = {true,true,true,true}


--[[  Testing LED's 1 at a time before asking user if it is on
		This got to be very repetitive, so I am turing on all at once and asking user once

		-- Cycling through LED's and asking user if working
		AddComment("LED D5")
		DUTDC:Write("GPIO",{LEDValue = D5, LEDMask = Mask})
			local re = prompt("\n Did LED D5 turn on?  (y/n) \n")
				if not (yes(re)) then
					evalLEDPF[1] = false
				end
		AddComment("User:  "..re)

		AddComment("\n LED D15")
		DUTDC:Write("GPIO",{LEDValue = D15, LEDMask = Mask})
			local re = prompt("\n Did LED D15 turn on?  (y/n) \n")
				if not (yes(re)) then
					evalLEDPF[2] = false
				end
		AddComment("User:  "..re)

		AddComment("\n LED D14")
		DUTDC:Write("GPIO",{LEDValue = D14, LEDMask = Mask})
			local re = prompt("\n Did LED D14 turn on?  (y/n) \n")
				if not (yes(re)) then
					evalLEDPF[3] = false
				end
		AddComment("User:  "..re)

		AddComment("\n LED D16")
		DUTDC:Write("GPIO",{LEDValue = D16, LEDMask = Mask})
			local re = prompt("\n Did LED D16 turn on?  (y/n) \n")
				if not (yes(re)) then
					evalLEDPF[4] = false
				end
		AddComment("User:  "..re)
		AddComment("\n") --print formatting



			--shutting off all LED's and creating fail message
			DUTDC:Write("GPIO",{LEDValue = 0x00, LEDMask = Mask})

				if evalLEDPF[1] == false then
					fMessage = fMessage .. "D5  "
				end

				if evalLEDPF[2] == false then
					fMessage = fMessage ..  "D15  "
				end

				if evalLEDPF[3] == false then
					fMessage = fMessage ..  "D14  "
				end

				if evalLEDPF[4] == false then
					fMessage = fMessage ..  "D16  "
				end



		--cycling through each LED to check for any fail
		for i= 1, 4 do
			LEDnum = LEDnum and evalLEDPF[i]
		end
--]]

		AddComment("LED D5, D15, D14, D16")
		DUTDC:Write("GPIO",{LEDValue = allLED, LEDMask = Mask})
			local re = prompt("\n\n Are all 8 LEDs on or flashing? \n (D19, D23, D17, D18, D5, D15, D14, and D16) \n (y/n)? \n")
				if not (yes(re)) then
					LEDcheck = false
				end
		AddComment("User:  "..re)



		--reporting pass/fail
        Check(LEDcheck)
	end
	},

	TestCase "Check Open Collectors"
	{
	function()

		--Using ChimeraCan to access Chimera Hardware (could use any communication protocol)
		--Initialize devicecomm objects with associated devIO commandset file
		DUTDC = DeviceComm.new( CommandSetPath )

		--Get default settings for the communication protocols
		DUTUserSettings = tcopy(DefaultUserSettings)

		--Initialize CAN communication
		DUTDC:Initialize("ChimeraCan", DUTUserSettings["ChimeraCan"])



			local Fail = false

			--Open all Collectors
			DUTDC:Write("OpenCollectors", { Value = 0x00, Mask = 0x0F })



		--OC1 test--**********************************************************
				AddComment("\n\n OC1 ON")
				DUTDC:Write("OpenCollectors", { Value = 0x01, Mask = 0x01 })
				local result = DUTDC:Do("REoutRead").RE0
				AddComment("RE0 read:  "..result)

					if (not (result == 0x00)) then
						Fail = true
						AddComment("\n FAIL")
						AddComment("OC1 ON should pull node to ground, RE0 not reading 0")
					end

				AddComment("\n OC1 OFF")
				DUTDC:Write("OpenCollectors", { Value = 0x00, Mask = 0x01 })
				result = DUTDC:Do("REoutRead").RE0
				AddComment("RE0 read:  "..result)

					if (not (result == 0x01)) then
						Fail = true
						AddComment("\n FAIL")
						AddComment("OC1 OFF should let node go high, RE0 not reading 1")
					end

		--OC2 test--**********************************************************
				AddComment("\n\n\n OC2 ON")
				DUTDC:Write("OpenCollectors", { Value = 0x02, Mask = 0x02 })
				local result = DUTDC:Do("REoutRead").RE2
				AddComment("RE2 read:  "..result)

					if (not (result == 0x00)) then
						Fail = true
						AddComment("\n FAIL")
						AddComment("OC2 ON should pull node to ground, RE2 not reading 0")
					end

				AddComment("\n OC2 OFF")
				DUTDC:Write("OpenCollectors", { Value = 0x00, Mask = 0x02 })
				result = DUTDC:Do("REoutRead").RE2
				AddComment("RE2 read:  "..result)

					if (not (result == 0x01)) then
						Fail = true
						AddComment("\n FAIL")
						AddComment("OC2 OFF should let node go high, RE2 not reading 1")
					end

		--OC3 test--**********************************************************
				AddComment("\n\n\n OC3 ON")
				DUTDC:Write("OpenCollectors", { Value = 0x04, Mask = 0x04 })
				local result = DUTDC:Do("REoutRead").RE4
				AddComment("RE4 read:  "..result)

					if (not (result == 0x00)) then
						Fail = true
						AddComment("\n FAIL")
						AddComment("OC3 ON should pull node to ground, RE4 not reading 0")
					end

				AddComment("\n OC3 OFF")
				DUTDC:Write("OpenCollectors", { Value = 0x00, Mask = 0x04 })
				result = DUTDC:Do("REoutRead").RE4
				AddComment("RE4 read:  "..result)

					if (not (result == 0x01)) then
						Fail = true
						AddComment("\n FAIL")
						AddComment("OC3 OFF should let node go high, RE4 not reading 1")
					end

		--OC4 test--**********************************************************
				AddComment("\n\n\n OC4 ON")
				DUTDC:Write("OpenCollectors", { Value = 0x08, Mask = 0x08 })
				local result = DUTDC:Do("REoutRead").RE6
				AddComment("RE6 read:  "..result)

					if (not (result == 0x00)) then
						Fail = true
						AddComment("\n FAIL")
						AddComment("OC4 ON should pull node to ground, RE6 not reading 0")
					end

				AddComment("\n OC4 OFF")
				DUTDC:Write("OpenCollectors", { Value = 0x00, Mask = 0x08 })
				result = DUTDC:Do("REoutRead").RE6
				AddComment("RE6 read:  "..result)

					if (not (result == 0x01)) then
						Fail = true
						AddComment("\n FAIL")
						AddComment("OC4 OFF should let node go high, RE6 not reading 1")
					end

					AddComment("\n\n")--print formatting

		--checking for failed test
		if Fail == true then
			Check(false,"OpenCollector Test Failed! \n Compare with GPIO Test! \n -")

		else
			Check(true)
		end
	end
	},

	TestCase "Check GPIO"
	{
	function()
		--Using ChimeraCan to access Chimera Hardware
		--Initialize devicecomm objects with associated devIO commandset file
		DUTDC = DeviceComm.new( CommandSetPath )

		--Get default settings for the communication protocols
		DUTUserSettings = tcopy(DefaultUserSettings)

		--Initialize CAN communication
		DUTDC:Initialize("ChimeraCan", DUTUserSettings["ChimeraCan"])



			local RE = {0,0,0,0,0,0,0,0}
			local GPIO_Pos = {"RE0","RE1","RE2","RE3","RE4","RE5","RE6","RE7"}
			local EvalRE_LOW = {true,true,true,true,true,true,true,true}
			local EvalRE_HIGH = {true,true,true,true,true,true,true,true}

			local Fail = false



		--open collectors OFF
		--test GPIO RE 0-7 can read logic HIGH
			AddComment("\n")
		DUTDC:Write("OpenCollectors", { Value = 0x00, Mask = 0x0F })
			AddComment("All Open Collectors OFF")
			AddComment("Lines let high")
			AddComment("\n")

		local result = DUTDC:Do("REoutRead")
			RE[1] = result.RE0
			RE[2] = result.RE1
			RE[3] = result.RE2
			RE[4] = result.RE3
			RE[5] = result.RE4
			RE[6] = result.RE5
			RE[7] = result.RE6
			RE[8] = result.RE7
				AddComment("Expected read:  1")

				for i=1,8 do
					AddComment("RE"..(i-1).." read:  "..RE[i])

					if RE[i] == 0x00 then
						EvalRE_LOW[i] = false
						AddComment("GPIO "..GPIO_Pos[i].." failed Low voltage read!")

						Fail = true
					end
				end



		--open collectors ON
		--test GPIO RE 0-7 can read logic LOW
			AddComment("\n")
		DUTDC:Write("OpenCollectors", { Value = 0x0F, Mask = 0x0F })
			AddComment("All Open Collectors ON")
			AddComment("Lines pulled low")
			AddComment("\n")

		result = DUTDC:Do("REoutRead")
			RE[1] = result.RE0
			RE[2] = result.RE1
			RE[3] = result.RE2
			RE[4] = result.RE3
			RE[5] = result.RE4
			RE[6] = result.RE5
			RE[7] = result.RE6
			RE[8] = result.RE7
				AddComment("Expected read:  0")

				for i=1,8 do
					AddComment("RE"..(i-1).." read:  "..RE[i])

					if RE[i] == 0x01 then
						EvalRE_HIGH[i] = false
						AddComment("GPIO "..GPIO_Pos[i].." failed High voltage read!")

						Fail = true
					end
				end



		--Test pass/fail
			AddComment("\n")
		if Fail == true then
			AddComment("\n Test Setup notes")
			AddComment("RE0/RE1 Pulled low by OC1")
			AddComment("RE2/RE3 Pulled low by OC2")
			AddComment("RE4/RE5 Pulled low by OC3")
			AddComment("RE6/RE7 Pulled low by OC4")

			Check(false,"GPIO Test Failed! \n Compare with Open Collector Test! \n -")

		else
			Check(true)
		end
	end
	},

	EachTeardown = function()
		--Align Pass/Fail/Pending message with comments
		io.write("\n", string.rep(" ", indent))
	end,

	Teardown = function()
		dec()
		--comment("End of test suite.", 0)
		dec()
	end,
}
--]]
--[[ Signal Conversion
--]]
--*******************************************************************************************Signal Conversion*******************************************************************************
--********************************************************************************************************************************************************************************
TestSuite "Signal Conversion"
{
	Setup = function()
		inc()
		comment("Basic.\n", 0)
		inc()
	end,

	TestCase "Check ADCs"
	{
	function()
		--Initialize devicecomm objects with associated devIO commandset file
		DUTDC = DeviceComm.new( CommandSetPath )

		--Get default settings for the communication protocols
		DUTUserSettings = tcopy(DefaultUserSettings)

		--Initialize CAN communication
		DUTDC:Initialize("ChimeraLin", DUTUserSettings["ChimeraLin"])



				local LCL = 1.45	--Upper/lower voltage limit
				local UCL = 1.55
				local errorMessage = ""

		local re = DUTDC:Read("Analog")
			AddComment("\n Expected Voltage:  1.5v")

			re.Ain1 = tonumber( string.format("%.3f", re.Ain1))	--formatting to have desired decimal places
			re.Ain2 = tonumber( string.format("%.3f", re.Ain2))

			AddComment("Ain1 actual:  " .. re.Ain1 .. "v")
			AddComment("Ain2 actual:  " .. re.Ain2 .. "v")



			--Check ADC Ain1
			if re.Ain1 >= LCL and re.Ain1 <= UCL then
				Ain1Result= true
			else
				Ain1Result= false
				errorMessage = "Ain1 ADC is out of range! Expected a value between "..LCL.."v and "..UCL.."v. Actual value was "..re.Ain1.."v"
			end



			--Check ADC Ain2
			if re.Ain2 >= LCL and re.Ain2 <= UCL then
				Ain2Result= true
			else
				Ain2Result= false
				errorMessage = errorMessage.."\n".."Ain2 ADC is out of range! Expected a value between "..LCL.."v and "..UCL.."v. Actual value was "..re.Ain2.."v"
			end
				AddComment("\n")



		--Test Result Pass/Fail
		Check(Ain1Result and Ain2Result, errorMessage.."\n")
	end
	},

	TestCase "Check DAC A"
	{
	function()
	--****************Testing setting Upper voltage for DAC A********************

		--establishing connection to DUT and tester
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

			--Changes from default occur here
			testerUserSettings.ChimeraLin.IP = "10.1.1.3"

			testerUserSettings.ChimeraLin.LinPort = "LIN1"
			DUTUserSettings.ChimeraLin.LinPort = "LIN1"

			testerCommandSettings.LIN.PadToFrameSize = 1
			DUTCommandSettings.LIN.PadToFrameSize = 1

			DUTUserSettings.ChimeraLin.AutoThreshold = "Disabled"
			DUTUserSettings.ChimeraLin.Threshold = "160"	--0.0685(v/step)   ~(11v)

		setModifiedSettings("ChimeraLin",
							testerCommandSettings, DUTCommandSettings,
							testerUserSettings, DUTUserSettings)



					AddComment("DAC A upper voltage test")
					AddComment("\n")

				--ensuring tester collector OC1 is OFF to connect DUT_1wire1 to tester_1Wire1
				testerDC:Write("OpenCollectors", { Value = 0x00, Mask = 0x0F })
					AddComment("Open Collectors OFF,  DUT 1Wire1 connected to tester 1Wire1")
					AddComment("\n")

				--using tester GPIO RE(0,1,2) to select 10k pulldown
				testerDC:Write("GPIO", { Value = 0x06, Mask = 0xFF, Direction = 0x00 })
					AddComment("10K pulldown resistor connected to 1Wire1")
					AddComment("\n")


						--[[ Tester GPIO table for selecting pulldown resistors

								write the following values using the tester chimera GPIO
								to select the following resistor on the given line. The
								pulldown resistors are connected to a mux and selected
								by the Tester GPIO REout pins.


								Write		Wire
								value		Selection		Resistance
							----------------------------------------------
								0x00		none			none
								0x04		1Wire 1			1k
								0x06		1Wire 1			10k
								0x07		1Wire 2			1k
								0x05		1Wire 2			10k
						--]]


		-- Send data from tester
			AddComment("Verifying ability to read data from tester 1Wire1")
		local data   = { 0xAA, 0xBB, 0xCC, 0xDD};
		testerDC:Do("SendData", {Data = data} )

		-- Read the result from the buffer
		local result = DUTDC:Do("ReadData")
			AddComment("\n")


				--Reseting open collectors and GPIO
				testerDC:Write("OpenCollectors", { Value = 0x00, Mask = 0x0F })
				testerDC:Write("GPIO", { Value = 0x00, Mask = 0xFF, Direction = 0x00 })
					AddComment("Open collectors and GPIO reset")


		CheckEqual(data, result.Data)
		AddComment("\n\n\n")



	--****************Testing setting Lower voltage for DAC A********************

		--establishing connection to DUT and tester
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

			--Changes from default occur here
			testerUserSettings.ChimeraLin.IP = "10.1.1.3"

			testerUserSettings.ChimeraLin.LinPort = "LIN1"
			DUTUserSettings.ChimeraLin.LinPort = "LIN1"

			testerCommandSettings.LIN.PadToFrameSize = 1
			DUTCommandSettings.LIN.PadToFrameSize = 1

			DUTUserSettings.ChimeraLin.AutoThreshold = "Disabled"
			DUTUserSettings.ChimeraLin.Threshold = "90"		--0.0685(v/step)   ~(6.3v)

		setModifiedSettings("ChimeraLin",
							testerCommandSettings, DUTCommandSettings,
							testerUserSettings, DUTUserSettings)


					AddComment("DAC A lower voltage test")
					AddComment("\n")

				--ensuring tester collector OC1 is OFF to connect DUT_1wire1 to tester_1Wire1
				testerDC:Write("OpenCollectors", { Value = 0x00, Mask = 0x0F })
					AddComment("Open Collectors OFF,  DUT 1Wire1 connected to tester 1Wire1")
					AddComment("\n")

				--using tester GPIO RE(0,1,2) to select 1k pulldown
				testerDC:Write("GPIO", { Value = 0x04, Mask = 0xFF, Direction = 0x00 })
					AddComment("1K pulldown resistor connected to 1Wire1")
					AddComment("\n")



		-- Send data from tester
			AddComment("Verifying ability to read data from tester 1Wire1")
		local data   = { 0xAA, 0xBB, 0xCC, 0xDD};
		testerDC:Do("SendData", {Data = data} )

		-- Read the result from the buffer
		local result = DUTDC:Do("ReadData")
			AddComment("\n")


				--Reseting open collectors and GPIO
				testerDC:Write("OpenCollectors", { Value = 0x00, Mask = 0x0F })
				testerDC:Write("GPIO", { Value = 0x00, Mask = 0xFF, Direction = 0x00 })
					AddComment("Open collectors and GPIO reset")


		CheckEqual(data, result.Data)
	end
	},

	TestCase "Check DAC B"
	{
	function()
	--****************Testing setting Upper voltage for DAC B********************

		--establishing connection to DUT and tester
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

			--Changes from default occur here
			testerUserSettings.ChimeraLin.IP = "10.1.1.3"

			testerUserSettings.ChimeraLin.LinPort = "LIN1"
			DUTUserSettings.ChimeraLin.LinPort = "LIN2"		--DUT Lin1,2 both connected to Tester Lin1

			testerCommandSettings.LIN.PadToFrameSize = 1
			DUTCommandSettings.LIN.PadToFrameSize = 1

			DUTUserSettings.ChimeraLin.AutoThreshold = "Disabled"
			DUTUserSettings.ChimeraLin.Threshold = "160"	--0.0685(v/step)   ~(11v)

		setModifiedSettings("ChimeraLin",
							testerCommandSettings, DUTCommandSettings,
							testerUserSettings, DUTUserSettings)



					AddComment("DAC B upper voltage test")
					AddComment("\n")

				--switching ON tester collector OC1 to connect DUT_1wire2 to tester_1Wire1
				testerDC:Write("OpenCollectors", { Value = 0x01, Mask = 0x0F })
					AddComment("Open Collector OC1 ON,  DUT 1Wire2 connected to tester 1Wire1")
					AddComment("\n")

				--using tester GPIO RE(0,1,2) to select 10k pulldown
				testerDC:Write("GPIO", { Value = 0x05, Mask = 0xFF, Direction = 0x00 })
					AddComment("10K pulldown resistor connected to 1Wire2")
					AddComment("\n")



		-- Send data
			AddComment("Verifying ability to read data from tester 1Wire1")
		local data   = { 0xAA, 0xBB, 0xCC, 0xDD};
		testerDC:Do("SendData", {Data = data} )

		-- Read the result from the buffer
		local result = DUTDC:Do("ReadData")
			AddComment("\n")



				--Reseting open collectors and GPIO
				testerDC:Write("OpenCollectors", { Value = 0x00, Mask = 0x0F })
				testerDC:Write("GPIO", { Value = 0x00, Mask = 0xFF, Direction = 0x00 })
					AddComment("Open collectors and GPIO reset")


		CheckEqual(data, result.Data)
		AddComment("\n\n\n")



	--****************Testing setting lower voltage for DAC B********************

		--establishing connection to DUT and tester
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

			--Changes from default occur here
			testerUserSettings.ChimeraLin.IP = "10.1.1.3"

			testerUserSettings.ChimeraLin.LinPort = "LIN1"
			DUTUserSettings.ChimeraLin.LinPort = "LIN2"

			testerCommandSettings.LIN.PadToFrameSize = 1
			DUTCommandSettings.LIN.PadToFrameSize = 1

			DUTUserSettings.ChimeraLin.AutoThreshold = "Disabled"
			DUTUserSettings.ChimeraLin.Threshold = "90"		--0.0685(v/step)   ~(6.3v)

		setModifiedSettings("ChimeraLin",
							testerCommandSettings, DUTCommandSettings,
							testerUserSettings, DUTUserSettings)



					AddComment("DAC B lower voltage test")
					AddComment("\n")

				--switching ON tester collector OCC1 to connect DUT_1wire2 to tester_1Wire1
				testerDC:Write("OpenCollectors", { Value = 0x01, Mask = 0x0F })
					AddComment("Open Collector OC1 ON,  DUT 1Wire2 connected to tester 1Wire1")
					AddComment("\n")

				--using tester GPIO RE(0,1,2) to select 1.5k pulldown
				testerDC:Write("GPIO", { Value = 0x07, Mask = 0xFF, Direction = 0x00 })
					AddComment("1K pulldown resistor connected to 1Wire2")
					AddComment("\n")



		-- Send data
			AddComment("Verifying ability to read data from tester 1Wire1")
		local data   = { 0xAA, 0xBB, 0xCC, 0xDD};
		testerDC:Do("SendData", {Data = data} )

		-- Read the result from the buffer
		local result = DUTDC:Do("ReadData")
			AddComment("\n")



			--Reseting open collectors and GPIO
			testerDC:Write("OpenCollectors", { Value = 0x00, Mask = 0x0F })
			testerDC:Write("GPIO", { Value = 0x00, Mask = 0xFF, Direction = 0x00 })
				AddComment("Open collectors and GPIO reset")


		CheckEqual(data, result.Data)
	end
	},

	EachTeardown = function()
		--Align Pass/Fail/Pending message with comments
		io.write("\n", string.rep(" ", indent))
	end,

	Teardown = function()
		dec()
		--comment("End of test suite.", 0)
		dec()
	end,
}
--]]
--[[ Voltage IO
--]]
--*******************************************************************************************Voltage IO*******************************************************************************
--********************************************************************************************************************************************************************************
TestSuite "Voltage IO"
{
	Setup = function()
		inc()
		comment("Basic.\n", 0)
		inc()
	end,


	--[[****NOTE ON V_BAT/IGN/REV HARDWARE****

				case BATTERY:
					if( charData == 0 ){
						CHM_LAT_V_BATT_ON = 0;
					}else if( charData == 1 ){
						CHM_LAT_V_BATT_ON = 1;

				case IGNITION:
					if( charData == 0 ){
						debug( "ign off",0,0,0,0);
						CHM_LAT_V_IGN_ON = 0;
					}else if( charData == 1 ){
						debug( "ign on",0,0,0,0);
						CHM_LAT_V_IGN_ON = 1;

				case REVERSE:
					if( charData == 0 ){
						CHM_LAT_V_REV_ON_HIGH = 0;
						CHM_LAT_V_REV_ON_LOW  = 1;
					}else if( charData == 1 ){
						CHM_LAT_V_REV_ON_HIGH  = 1;
						CHM_LAT_V_REV_ON_LOW  = 0;
					}else if( charData == 2 ){
						CHM_LAT_V_REV_ON_HIGH  = 0;
						CHM_LAT_V_REV_ON_LOW  = 0;

	Source:
	http://vcs.gentex.com/svn/tools/projects/Chimera/trunk/firmware/chimera.c
	--]]


	TestCase "Check Ignition"
	{
	function()
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

			--Changes from default occur here
			testerUserSettings.ChimeraCan.IP = "10.1.1.3"

		setModifiedSettings("ChimeraCan",
							testerCommandSettings, DUTCommandSettings,
							testerUserSettings, DUTUserSettings)



			local gain =  6.76 		--voltage gain from voltage divider on tester
			local V_on = 14.6 		--expected voltage, slightly less than Vunreg=14.8
			local tol = .1 			--tolerance for test pass/fail

			local Vhigh = (V_on + (V_on * tol))
			local Vlow = (V_on - (V_on * tol))


		--all three lines are connected to same node on test
		--V_IGN and V_BAT are switched off, V_REV to Open/Comm
			AddComment("V_IGN: OFF,  V_BAT: OFF,  V_REV: OPEN/COMM")
		DUTDC:Write("Ignition", { State = 0x00})
		DUTDC:Write("Battery", { State = 0x00})
		DUTDC:Write("Reverse", { State = 0x02})
			AddComment("\n")



			--verify the line voltage is low
			local re = (tonumber(string.format("%.3f",testerDC:Read("Analog").Ain1))) * gain  --formatting for 3 decimal places and multiplying gain from voltage divider

				AddComment("Line voltage:  "..re.."v")
				AddComment("expected:  0v ")

				if re ~= 0 then  --if voltage is not low, fail test
					AddComment("Line Voltage not 0 as expected!")
					Check(false,"V_IGN, V_BAT, or V_REV is not switching off completely")
				end


		--switch on the ignition line
			AddComment("\n V_IGN: ON,  V_BAT: OFF,  V_REV: OPEN/COMM")
		DUTDC:Write("Ignition", { State = 0x01})




			--check voltage
				AddComment("\n")
			re = (tonumber(string.format("%.3f",testerDC:Read("Analog").Ain1))) * gain
				AddComment("\n Line voltage:  "..re.."v")
				AddComment("expected:  "..V_on.."v")
				AddComment("\n")

		Check(((re >= Vlow) and (re <= Vhigh)),"Voltage out of "..(tol*100).."% tolerance!")

	end
	},

	TestCase "Check Battery"
	{
	function()
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

			--Changes from default occur here
			testerUserSettings.ChimeraCan.IP = "10.1.1.3"

		setModifiedSettings("ChimeraCan",
							testerCommandSettings, DUTCommandSettings,
							testerUserSettings, DUTUserSettings)

			local gain =  6.76 		--voltage gain from voltage divider on tester
			local V_on = 14.6		--expected voltage, slightly less than Vunreg=14.8
			local tol = .1 			--tolerance for test pass/fail

			local Vhigh = (V_on + (V_on * tol))
			local Vlow = (V_on - (V_on * tol))




		--all three lines are connected to same node on test
		--V_IGN and V_BAT are switched off, V_REV to Open/Comm
			AddComment("V_IGN: OFF,  V_BAT: OFF,  V_REV: OPEN/COMM")
		DUTDC:Write("Ignition", { State = 0x00})
		DUTDC:Write("Battery", { State = 0x00})
		DUTDC:Write("Reverse", { State = 0x02})




			--verify the line voltage is low
				AddComment("\n")
			local re = (tonumber(string.format("%.3f",testerDC:Read("Analog").Ain1))) * gain  --formatting for 3 decimal places and multiplying gain from voltage divider
				AddComment("Line voltage:  "..re.."v")
				AddComment("expected:  0v ")

				if re ~= 0 then  --if voltage is not low, fail test
					AddComment("Voltage not 0 as expected!")
					Check(false,"V_IGN, V_BAT, or V_REV is not swtiching off completely")
				end



		--switch on the battery line
			AddComment("\n V_IGN: OFF,  V_BAT: ON,  V_REV: OPEN/COMM")
		DUTDC:Write("Battery", { State = 0x01})


			--check voltage
				AddComment("\n")
			re = (tonumber(string.format("%.3f",testerDC:Read("Analog").Ain1))) * gain
				AddComment("\n Line voltage:  "..re.."v")
				AddComment("expected:  "..V_on.."v ")
				AddComment("\n")

		Check(((re >= Vlow) and (re <= Vhigh)),"Voltage out of "..(tol*100).."% tolerance!")
	end
	},

	TestCase "Check Reverse"
	{
	function()
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

			--Changes from default occur here
			testerUserSettings.ChimeraCan.IP = "10.1.1.3"

		setModifiedSettings("ChimeraCan",
							testerCommandSettings, DUTCommandSettings,
							testerUserSettings, DUTUserSettings)



			local gain =  6.76 			--voltage gain from voltage divider on tester
			local V_on = 14.6			--expected voltage, slightly less than Vunreg=14.8
			local tol = .1 				--tolerance for test pass/fail

			local Vhigh = (V_on + (V_on * tol))
			local Vlow = (V_on - (V_on * tol))



		--all three lines are connected to same node on test
		--V_IGN and V_BAT are switched off, V_REV to Open/Comm
			AddComment("V_IGN: OFF,  V_BAT: OFF,  V_REV: OPEN/COMM")
		DUTDC:Write("Ignition", { State = 0x00})
		DUTDC:Write("Battery", { State = 0x00})
		DUTDC:Write("Reverse", { State = 0x02})



			--verify the line voltage is low
			--this also verifies the voltage for V_REV Open/Comm
				AddComment("\n")
			local re = (tonumber(string.format("%.3f",testerDC:Read("Analog").Ain1))) * gain  --formatting for 3 decimal places and multiplying gain from voltage divider
				AddComment("Line voltage:  "..re.."v")
				AddComment("expected:  0v ")

				if re ~= 0 then  --if voltage is not low, fail test
					AddComment("Voltage not 0 as expected!")
					Check(false,"V_IGN, V_BAT, or V_REV is not switching off completely")
				end



		--Verify V_REV off
			AddComment("\n V_IGN: OFF,  V_BAT: OFF,  V_REV: OFF")
		DUTDC:Write("Reverse", { State = 0x00})


			--read voltage
			local re_off = ( ( tonumber( string.format("%.2f", (testerDC:Read("Analog").Ain1) ) ) ) * gain)
				AddComment("\n Line voltage:  "..re_off.."v")
				AddComment("expected:  0v")
				AddComment("\n")

		--test pass/fail for V_REV off
		CheckEqual(0, re_off)



		--Verify V_REV on
			AddComment("\n V_IGN: OFF,  V_BAT: OFF,  V_REV: ON")
		DUTDC:Write("Reverse", { State = 0x01})


			--read voltage
				AddComment("\n")
			local re_on = ( ( tonumber( string.format("%.2f", (testerDC:Read("Analog").Ain1) ) ) ) * gain)
				AddComment("\n Line voltage:  "..re_on.."v")
				AddComment("expected:  "..V_on.."v".."")
				AddComment("\n")

		--test pass/fail
		Check(((re_on >= Vlow) and (re_on <= Vhigh)),"Voltage out of "..(tol*100).."% tolerance!")



		--Notes to translate whats going on for hardware
		--compare with chimera schematic
		if( (re_on <= Vlow) or (re_on >= Vhigh) or (re_off ~= 0) ) then
			AddComment("\n NOTE: \n\t Compare with Chimera schematic for V_REV on power supply sheet")
			AddComment("\n V_REV: OFF \n\t V_REV_ON_HIGH = 0 \n\t V_REV_ON_LOW  = 1")
			AddComment("\n V_REV: ON \n\t V_REV_ON_HIGH = 1 \n\t V_REV_ON_LOW  = 0")
			AddComment("\n V_REV: OPEN/COMM \n\t V_REV_ON_HIGH = 0 \n\t V_REV_ON_LOW  = 0")
			AddComment("")
		end

	end
	},

	EachTeardown = function()
		--Align Pass/Fail/Pending message with comments
		io.write("\n", string.rep(" ", indent))
	end,

	Teardown = function()
		dec()
		--comment("End of test suite.", 0)
		dec()
	end,
}
--]]
--[[ Configuration Persistence
--
TestSuite "Configuration Persistence"
{
	Setup = function()
		inc()
		comment("Basic.\n", 0)
		inc()
	end,

	TestCase "Not a test case"
	{
	function()
		Pending()
		comment("Test writing to the NVM and resetting.")
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
--[[ I2C
--]]
--*******************************************************************************************I2C***************************************************************************
--*************************************************************************************************************************************************************************************
TestSuite "I2C"
{
	Setup = function()
		inc()
		comment("Basic.\n", 0)
		inc()
	end,

	TestCase "Check I2C"
	{
	function()
		testerCommandSettings, DUTCommandSettings,
		testerUserSettings, DUTUserSettings = getDefaultSettings()

			--Changes from default occur here
			--I2C Address of EEPROM 24AA32A to use for test
			DUTCommandSettings.I2C.Address = 0xA0

		setModifiedSettings("ChimeraI2C",
						testerCommandSettings, DUTCommandSettings,
						testerUserSettings, DUTUserSettings)

			AddComment("I2C EEPROM address:  0xA0".."\n".."Note:  This address is hardwired on the debug PCB board")
			AddComment("\n")


			--Value stored on EEprom device at EEpromAddress is manually selected and written to prior to test
			local WriteAddress = {0x0A, 0xAA}
			local DataValue = {0xAA, 0xBB, 0xBB, 0xEE}



		--writing value
		local result = DUTDC:Do("WriteEEprom", {Address=WriteAddress, Data=DataValue} )
			AddComment(DataValue[1]..", "..DataValue[2]..", "..DataValue[3]..", "..DataValue[4].." written to address:  "..WriteAddress[1]..", "..WriteAddress[2])
			AddComment("\n")

		--reading value back
		local result = DUTDC:Do("ReadEEprom", {Address=WriteAddress} )
			AddComment(result.Data[1]..", "..result.Data[2]..", "..result.Data[3]..", "..result.Data[4].."  read from address:  "..WriteAddress[1]..", "..WriteAddress[2])
			AddComment("\n")


		--Verify that data transmitted is the same as data received.
		CheckEqual(DataValue, result.Data)






--Reseting Chimera due to Dallas errorMessage
--Dallas chip only detected if ChimeraCan communication has not been established before
--Must reset chimera with each run to allow Dallas test to work properly
--move this to end of test if adding more tests below
DUTDC:Do("ResetChimera")
testerDC:Do("ResetChimera")





	end
	},

	EachTeardown = function()
		--Align Pass/Fail/Pending message with comments
		io.write("\n", string.rep(" ", indent))
	end,

	Teardown = function()
		dec()
		--comment("End of test suite.", 0)
		dec()
	end,
}
--]]
--[[ Other Protocols
--]]
--*******************************************************************************************Other Protocols***************************************************************************
--*************************************************************************************************************************************************************************************
TestSuite "Other Protocols"
{
	Setup = function()
		inc()
		comment("Basic.\n", 0)
		inc()
	end,

	TestCase "Check SPI"
	{
	function()
		Pending()
		comment("Test Suite written only when SPI is developed for the Chimera.")
		AddComment("SPI functionality not currently supported by chimera firmware")

	end
	},

	EachTeardown = function()
		--Align Pass/Fail/Pending message with comments
		io.write("\n", string.rep(" ", indent))
	end,

	Teardown = function()
		dec()
		--comment("End of test suite.", 0)
		dec()
	end,
}
--]]




