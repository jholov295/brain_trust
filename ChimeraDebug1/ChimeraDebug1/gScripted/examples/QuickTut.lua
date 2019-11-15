-- ---------------------------------------------------------------------------
-- Quick tutorial - http://eeweb/redmine/wiki/gscripted/Quick_Tutorial
-- ---------------------------------------------------------------------------

-- INCLUDES ------------------------------------------------------------------
--
require( "gScripted" )
local String	= require( "String" )

-- FILE LEVEL VARIABLES -------------------------------------------------------
--
local devComm = nil

-- HELPER FUNCTIONS -----------------------------------------------------------
--
-- Initializes the DeviceComm object
function InitRevComm()
	local hardwareSettings =
	{
		Port			="COM1",
		--Baud			= 38400,
		--ReadLoopback	= "true",
		--AssertRTS		= "true"
	}

	PrintLog( TRACE, "-- Trying to create a DeviceComm object" )

	if nil == devComm then
		print( "devComm not initialized" )
		devComm = DeviceComm.new( "RevComm.xml" )
	end

	devComm:Initialize( "RevCommBoard", hardwareSettings )

	-- Unlock the mirror. The DeviceComm functions will throw and end your
	-- program. This way you know there was an error.
	devComm:Do( "Unlock" )
end

-- Runs the actual tests on the mirror
function TestMirror()
	-- Ask the mirror for it's serial number.
	PrintLog( TRACE, "Read the mirrors serial number..." )
	local serialNumber = devComm:Do( "ReadManufacturingData" ).serialNumber
	print( "Serial number="..String.ToHex( serialNumber ) )

	-- Ask the mirror for it's EA part number.
	PrintLog( TRACE, "Read the mirrors EA part number..." )
	local eaPartNumber = devComm:Do( "ReadManufacturingData" ).eaPartNumber
	print( "Part number="..String.ToHex( eaPartNumber ) )

	-- Loop a command 20 times as fast as the communications library allows.
	for i = 1, 20 do
		local responses = devComm:Do( "ReadALSCalData" )
		print( "Sending ReadALSCalData message "..i )
		if ( type( responses ) == "table" ) then
			for k, response in pairs( responses ) do
				print( "ALSCalData["..k.."] = " .. String.ToHex( response ) .. "(".. String.ToDec( response ) ..")" )
			end
		end
	end
end

-- MAIN -----------------------------------------------------------------------
--
function main()
	InitRevComm()
	TestMirror()
end

main()
