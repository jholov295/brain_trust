-- ---------------------------------------------------------------------------
-- Quick tutorial - http://eeweb/redmine/wiki/gscripted/Quick_Tutorial
-- ---------------------------------------------------------------------------

-- INCLUDES ------------------------------------------------------------------
--
require( "gScripted" )
local String = require( "bit" )

-- FILE LEVEL VARIABLES -------------------------------------------------------
--
local devComm = nil

-- HELPER FUNCTIONS -----------------------------------------------------------
--
-- Initializes the DeviceComm object
function InitBaseRevComm()
	local hardwareSettings =
	{
		Port			= arg[1] or "10.1.1.2",
	}

	PrintLog( TRACE, "-- Trying to create a DeviceComm object" )

	if nil == devComm then
		print( "devComm not initialized" )
		devComm = DeviceComm.new( "BaseRevComm.cmdset" )
	end

	devComm:Initialize( "ChimeraRevComm", hardwareSettings )

	-- Unlock the mirror. The DeviceComm functions will throw and end your
	-- program. This way you know there was an error.
	devComm:Do( "Unlock" )
end

-- Runs the actual tests on the mirror
function TestMirror()
	-- Ask the mirror for it's serial number.
	--PrintLog( TRACE, "Read the mirrors serial number..." )
	--local serialNumber = devComm:Do( "ReadManufacturingData" ).serialNumber
	--print( "Serial number="..String.ToHex( serialNumber ) )

	-- Ask the mirror for it's EA part number.
	PrintLog( TRACE, "Dumping the NVM to 'dump.csv'..." )
	devComm:Do( "DumpNVMtoCSV", { path = "nvm_dump.csv" } )

	-- Loop a command 20 times as fast as the communications library allows.
	for i = 1, 20 do
		local responses = devComm:Do( "ReadALSCalData" )
		print( "Sending ReadALSCalData message "..i )
		if ( type( responses ) == "table" ) then
			for k, response in pairs( responses ) do
				print( "ALSCalData["..k.."] = 0x" .. bit.tohex( response, 4 ):upper() .. " (".. response ..")" )
			end
		end
	end
end

-- MAIN -----------------------------------------------------------------------
--
function main()
	InitBaseRevComm()
	TestMirror()
end

main()
