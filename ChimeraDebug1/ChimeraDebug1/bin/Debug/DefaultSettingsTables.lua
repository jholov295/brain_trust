--- Command Settings : Control the protocol settings
DefaultCommandSettings = {
	CAN = {
		BitRate = 100000,
		--[[
			Type: U32
			Desc: Bit rate of the CAN network, in bits per second.
		--]]
		DestinationId = 0x00000001,
		--[[
			Type: U32
			Desc: ID used when the device transmits to the PC.
				Use 0xFFFFFFFE if you don't care.
				NOTE: This is the integer value 4294967294 = (2^32) - 2
				as seen in tprint and ChimeraDebug
		--]]
		FlowControlBlockSize = 0,
		--[[
			Type: U8
		--]]
		FlowControlFrameSeparationTime = 0,
		--[[
			Type: U8
		--]]
		IdSize = 11,
		--[[
			Type: U32
			--Note: This may be simply because it's a C++ int, rather than U8
			Desc: 11 or 29 bits.
		--]]
		PadToFrameSize = 0,
		--[[
			Type: U8 (Boolean)
			Desc: Extend transmitted frames
					with 0x00 until they are 8 bytes long.
					1 = true
					0 = false
		--]]
		RxPrefix = {
		},
		--[[
			Type: U8[]
			Desc: Prefix to remove from each incoming frame before processing.
		--]]
		SourceId = 0x00000001,
		--[[
			Type: U32
			Desc: ID used when the PC transmits to the device.
				Use 0xFFFFFFFFE if you don't care.
		--]]
		Transceiver = 0,
		--[[
			Type: U8
			Desc: Selects the transciever to be used for transmission.
					0 = LowSpeed
					1 = HighSpeed
					2 = SingleWire
		--]]
		TxPrefix = {
		},
		--[[
			Type: U8[]
			Desc: Prefix inserted on each outgoing frame.
		--]]
		UsePCIByte = 0,
		--[[
			Type: U8
			Desc: Automatically calculate and insert PCI byte into transmitted
					frames.
					1 = true
					0 = false
		--]]
		},
	I2C = {
		Address = 0,
		--[[
			Type: U8
			Desc: Address of the I2C device.
		--]]
		BitRate = 100000,
		--[[
			Type: U32
			Desc: Bit rate of the I2C network, in bits per second.
		--]]
		},
	LIN = {
		BitRate = 9600,
		--[[
			Type: U32
			Desc: Bit rate of the CAN network, in bits per second.
		--]]
		ContinuousWakeup = 1,
		--[[
			Type: U8
		--]]
		DestinationId = 0x00000001,
		--[[
			Type: U32
			Desc: Slave frame ID. ID used when the device transmits to the PC.
					Use 0xFFFFFFFE if you don't care.
		--]]
		P2 =1000,
		--[[
			Type: U16
			Desc: Time in milliseconds between reception of the last frame of
					a diagnostic request on the LIN bus and the slave node
					being able to provide data for a response.  The maximum
					value defines the time after which a slave node must
					have recieved a slave response header before it discards
					its response.  Each slave node defines this minimum
					value in the NCF, see Node Capability Language
					Specification.
		--]]
		PadToFrameSize = 0,
		--[[
			Type: U8 (Boolean)
			Desc: Extend transmitted frames
					with 0x00 until they are 8 bytes long.
					1 = true
					0 = false
		--]]
		RxPrefix = {
			},
		--[[
			Type: U8[]
			Desc: Prefix expected on incoming frames.
		--]]
		SourceId = 0x00000001,
		--[[
			Type: U32
			Desc: Slave frame ID. ID used when the PC transmits to the device.
					Use 0xFFFFFFFE if you don't care.
		--]]
		STmin = 0,
		--[[
			Type: U8
			Desc: The minimum time in milliseconds the slave node needs to
					prepare the reception of the next frame of a diagnostic
					request or the transmission of the next frame of a
					diagnostic response.  Each slave node defines this minimum
					value in the NCF, see Node Capability Language
					Specification.
		--]]
		TxPrefix = {
			},
		--[[
			Type: U8[]
			Desc: Prefix inserted on each outgoing frame.
					LIN 1.3: 2 bytes, Command and Node Address
					LIN 2.0: 1 byte, Node Address
		--]]
		UsePCIByte = 1,
		--[[
			Type: U8
			Desc: Automatically calculate and insert PCI byte into transmitted
					frames.
					1 = true
					0 = false
		--]]
		Version = 1.3,
		--[[
			Type: D64
			Desc: Version of the LIN protocol.
					LIN 1.3: 1.3
					LIN 2.0: 2.0
		--]]
		},
	Serial = {
		BitRate = 9600,
		--[[
			Type: U32
			Desc: Baud of serial port.
		--]]
		DataBits = 8,
		--[[
			Type: U32
			Desc: Number of Data Bits for serial port.
		--]]
		RxPrefix = {
			},
		--[[
			Type: U8[]
			Desc: Prefix to remove from incoming data before processing it.
		--]]
		RxSuffix = {
			},
		--[[
			Type: U8[]
			Desc: Series of bytes that are used to find the end of the
					incoming data.
		--]]
		TxPrefix = {
			},
		--[[
			Type: U8[]
			Desc: Prefix inserted on outgoing data.
		--]]
		TxSuffix = {
			},
		--[[
			Type: U8[]
			Desc: Series of bytes that are appended to outgoing data.
		--]]
		},
}

--- User Settings : Control the hardware preferences
DefaultUserSettings = {
	CAN232 = {
			--[[Serial Port--]]
			Port = "COM1",				--"COM2"
	},
	ChimeraCan = {
			--[[Chimera Can Port--]]
			CanPort = "Muxed",			--"HighSpeed"
			--[[Each simultaneous connection must have its own channel
				ex. CAN on Channel 1, LIN on Channel 2.	--]]
			Channel = "1", 				--"2"
			--[[Internet Protocol address--]]
			IP = "10.1.1.2",			--"10.1.1.3"
	},
	ChimeraDallas = {
			--[[Each simultaneous connection must have its own channel
				ex. CAN on Channel 1, LIN on Channel 2.--]]
			Channel = "1", 				--"2"
			--[[ID = "0x0011223344556677"--]]
			["Dallas Id"] = "0x0011223344556677",
			--[[Internet Protocol address--]]
			IP = "10.1.1.2",			--"10.1.1.3"
	},
	ChimeraI2C = {
			--[[Each simultaneous connection must have its own channel
				ex. CAN on Channel 1, LIN on Channel 2.--]]
			Channel = "1", 				--"2"
			--[[Internet Protocol address--]]
			IP = "10.1.1.2",			--"10.1.1.3"
	},
	ChimeraLin = {
			--[[Automatically determine the best trigger level for
				recomm responses; may require 1 or 2 additional calls
				to unlock.--]]
			AutoThreshold = "Enabled",	--"Disabled"
			--[[Each simultaneous connection must have its own channel
				ex. CAN on Channel 1, LIN on Channel 2.--]]
			Channel = "1", 				--"2"
			--[[Internet Protocol address--]]
			IP = "10.1.1.2",			--"10.1.1.3"
			--[[Chimera Lin Port--]]
			LinPort = "LIN2",			--"LIN1"
			--[[Pullup resistor on SingleWire Port 1 (RevComm)--]]
			PullupSelection = "1.5k",	--"2.2k", "6.8k", "10k", "Open" --TODO: Check open
			--[[If AutoThreshold is disabled, this is the value that the
				DAC will be set to.--]]
			Threshold = "0",			--"1", "2", ...
			--[[UART--]]
			Uart = "1",
	},
	ChimeraRevComm = {
			--[[Automatically determine the best trigger level for
				revcomm responses; may require 1 or 2 additional calls
				to unlock.--]]
			AutoThreshold = "Enabled",
			--[[Each simultaneous connection must have its own channel
				ex. CAN on Channel 1, LIN on Channel 2.--]]
			Channel = "1", 				--"2"
			--[[Internet Protocol address--]]
			IP = "10.1.1.2",			--"10.1.1.3"
			--[[Pullup resistor on SingleWire Port 1 (RevComm)--]]
			PullupSelection = "1.5k",	--"2.2k", "6.8k", "10k", "Open" --TODO: Check open
			--[[Chimera RevComm Port--]]
			RevCommPort = "RevComm1",
			--[[If AutoThreshold is disabled, this is the value that the
				DAC will be set to.--]]
			Threshold = "0",			--"1", "2", ...
			--[[UART--]]
			Uart = "1",					--"2"
	},
	ChimeraSDL = {
			--[[Each simultaneous connection must have its own channel
				ex. CAN on Channel 1, LIN on Channel 2.--]]
			Channel = "1", 				--"2"
			--[[Internet Protocol address--]]
			IP = "10.1.1.2",			--"10.1.1.3"
			--[[Chimera SDL Port--]]
			SDLPort = "SDL1",			--"SDL2"
	},
	ChimeraSerial = {
			--[[Each simultaneous connection must have its own channel
				ex. CAN on Channel 1, LIN on Channel 2.--]]
			Channel = "1", 				--"2"
			--[[Indicate the flow control mode for RS232--]]
			FlowControl = "None",		--"Hardware"
			--[[Internet Protocol address--]]
			IP = "10.1.1.2",			--"10.1.1.3"
			--[[Serial Transmission Protocol--]]
			Mode = "RS232",				--"422", "485"
			--[[UART--]]
			Uart = "1",					--"2"
	},
	LIN232 = {
			--[[Serial Port--]]
			Port = "COM1",				--"COM2"
	},
	RevCommBoard = {
			--[[Serial Port--]]
			Port = "COM1",				--"COM2"
	},
	Serial = {
			--[[Serial Port--]]
			Port = "COM1",				--"COM2"
			--[[Expect and discard echo of transmissions--]]
			ReadLoopback = "0",			--"1"
	},
	VectorCAN = {
	},
	VectorLIN = {
			--[[LIN master or slave--]]
			Mode = "Master",			--"Slave"
	},
}

--[[
DefaultCommandSettings = protectTable(DefaultCommandSettings)
DefaultUserSettings	= protectTable(DefaultUserSettings)
--]]
