-- ---------------------------------------------------------------------------
--	RevComm.lua - Example scipt that shows how to talk to RevComm mirrors.
--
--	Author:		Ryan Pusztai
--	Date:		11/13/2008
--	Version:	1.00
--
--	NOTES:
--				* Requires gScripted version 2.0+
-- ---------------------------------------------------------------------------

-- INCLUDES ------------------------------------------------------------------
--
require( "gScripted" )
require( "String" )
require( "Utils" )

-- CHECK VERSION -------------------------------------------------------------
--
if gScripted.version < 2.0 then
    -- Do 0.9 specific stuff
	error("gScripted v"..gScripted.version.." found. Only gScripted version 2.0+ is supported.")
end

-- MAIN CODE -----------------------------------------------------------------
--

function CallDo( dcObj, functionName, namedParameters )
	print( "Calling "..functionName.."..." )

	-- Find the command.
	local cmdParams = dcObj[functionName]

	-- Print the commands details.
	print( "|-- "..cmdParams.Name.." parameters" )
	for k, v in pairs( cmdParams ) do
		print( "", k, v )
		if "table" == type( cmdParams[k] ) then
			for k, v in pairs( cmdParams[k] ) do print( "", "", k, v ) end
		end
	end

	-- Set the In paramters of the command.
	if namedParameters then
		for k, v in pairs( namedParameters ) do
			cmdParams.In[k] = v
		end
	end

	-- Display the In parameters.
	print( "|--", "In", "table:" )
	for inParameterName, inParameterValue in pairs( cmdParams.In ) do
		print( "", "", inParameterName, inParameterValue )
	end

	-- Send the command using a LuaCommand.
	print( "-- Sending "..cmdParams.Name.." using a LuaCommand class" )
	local retVal = dcObj:Do( cmdParams )
	-- Display the Out parameters.
	print( retVal.Name.." returned:" )
	if retVal then
		for parameterName, parameterValue in pairs( retVal.Out ) do
			print( "", parameterName, String.ToHex( parameterValue ), "["..String.ToDec( parameterValue ).."]" )
		end
	end

	-- Send the command using a function name and named parameters.
	print( "-- Sending "..functionName.." using the function name." )
	local retVal = dcObj:Do( functionName, namedParameters )
	-- Display the returned parameters.
	print( functionName.." returned:" )
	for parameterName, parameterValue in pairs( retVal ) do
		print( "", parameterName, String.ToHex( parameterValue ), "["..String.ToDec( parameterValue ).."]" )
	end
end

function CallRead( dcObj, functionName )
	print( "Calling "..functionName.."..." )

	-- Find the command.
	local cmdParams = dcObj[functionName]

	-- Print the commands details.
	print( "|-- "..cmdParams.Name.." parameters" )
	for k, v in pairs( cmdParams ) do
		print( "", k, v )
		if "table" == type( cmdParams[k] ) then
			for k, v in pairs( cmdParams[k] ) do print( "", "", k, v ) end
		end
	end

	-- Display the Mem parameters.
	print( "|--", "Mem", "table:" )
	for memParameterName, memParameterValue in pairs( cmdParams.Mem ) do
		print( "", "", memParameterName, memParameterValue )
	end

	-- Send the command using a LuaCommand.
	print( "-- Sending "..cmdParams.Name.." using a LuaCommand class" )
	local retVal = dcObj:Read( cmdParams )
	-- Display the Out parameters.
	print( retVal.Name.." returned:" )
	if retVal then
		for parameterName, parameterValue in pairs( retVal.Mem ) do
			print( "", parameterName, String.ToHex( parameterValue ), "["..String.ToDec( parameterValue ).."]" )
		end
	end

	-- Send the command using a function name and named parameters.
	print( "-- Sending "..functionName.." using the function name." )
	local retVal = dcObj:Read( functionName )
	-- Display the returned parameters.
	print( functionName.." returned:" )
	for parameterName, parameterValue in pairs( retVal ) do
		print( "", parameterName, String.ToHex( parameterValue ), "["..String.ToDec( parameterValue ).."]" )
	end
end

function CallWrite( dcObj, functionName, namedParameters )
	print( "Calling "..functionName.."..." )

	-- Find the command.
	local cmdParams = dcObj[functionName]

	-- Print the commands details.
	print( "|-- "..cmdParams.Name.." parameters" )
	for k, v in pairs( cmdParams ) do
		print( "", k, v )
		if "table" == type( cmdParams[k] ) then
			for k, v in pairs( cmdParams[k] ) do print( "", "", k, v ) end
		end
	end

	-- Set the Mem paramters of the command.
	if namedParameters then
		for k, v in pairs( namedParameters ) do
			cmdParams.Mem[k] = v
		end
	end

	-- Display the Mem parameters.
	print( "|--", "Mem", "table:" )
	for memParameterName, memParameterValue in pairs( cmdParams.Mem ) do
		print( "", "", memParameterName, memParameterValue )
	end

	-- Send the command using a LuaCommand.
	print( "-- Sending "..cmdParams.Name.." using a LuaCommand class" )
	local retVal = dcObj:Write( cmdParams )
	-- Display the Out parameters.
	print( retVal.Name.." returned:" )
	if retVal then
		for parameterName, parameterValue in pairs( retVal.Mem ) do
			print( "", parameterName, String.ToHex( parameterValue ), "["..String.ToDec( parameterValue ).."]" )
		end
	end

	-- Send the command using a function name and named parameters.
	print( "-- Sending "..functionName.." using the function name." )
	local retVal = dcObj:Write( functionName, namedParameters )
	-- Display the returned parameters.
	print( functionName.." returned:" )
	for parameterName, parameterValue in pairs( retVal ) do
		print( "", parameterName, String.ToHex( parameterValue ), "["..String.ToDec( parameterValue ).."]" )
	end
end


function main()
	print( "-- Trying to create a DeviceComm object" )
	local devComm
	if nil == devComm then
		print( "devComm not initialized" )
		devComm = DeviceComm.new( "RevComm.xml" )
	end
	print( "Name:", devComm:GetName() )
	--print( "-- DeviceComm Object table" )
	--for k, v in pairs( devComm ) do print( "devComm."..k, v ) end

	local settings = { Port = "COM1" }

	devComm:Initialize( "RevCommBoard", settings )

	print( "-- DeviceComm Initialized" )

	-- Unlock
	CallDo( devComm, "Unlock" )
	CallDo( devComm, "Unlock" )
	CallDo( devComm, "Unlock" )

	-- ReadALSCalData
	CallDo( devComm, "ReadALSCalData" )

	-- ReadAmbientIntegrationReturnPulse
	CallDo( devComm, "ReadAmbientIntegrationReturnPulse", { integrationTime = 1000 } )

	-- ReadGlareIntegrationReturnPulse
	CallDo( devComm, "ReadGlareIntegrationReturnPulse", { integrationTime = 500 } )

	-- ReadManufacturingData
	CallDo( devComm, "ReadManufacturingData" )

	-- Read AmbientCal
	CallRead( devComm, "AmbientCal" )

	-- Write AmbientCal using a hex value
	CallWrite( devComm, "AmbientCal", { cal = 0x1200 } )

	-- Read AmbientCal
	CallRead( devComm, "AmbientCal" )

	-- Write AmbientCal using a decimal value
	CallWrite( devComm, "AmbientCal", { cal = 4505 } )

	print( "-- Shutting down the DeviceComm object" )
	devComm:Shutdown()

	devComm:Initialize( "RevCommBoard", settings )
	CallDo( devComm, "Unlock" )
	-- ReadALSCalData
	CallDo( devComm, "ReadALSCalData" )

	-- Release hardware
	devComm:Shutdown()
end

if not _LEXECUTOR then
	main()
end
