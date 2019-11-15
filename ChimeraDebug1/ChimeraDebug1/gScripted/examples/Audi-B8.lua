-- ---------------------------------------------------------------------------
--	Audi-B8.lua - Example scipt that shows how to work with CAN mirrors.
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

function OnHBStatus( command )
	-- Right now you can't call any gScripted commands from a callback. --Log( ERROR, "HBStatus: "..command.Out["HBStatus"].." HBOffReasonCode:"..command.Out["HBOffReasonCode"] )
	-- Simply display the HBStatus.
	for k, v in pairs( command.Out ) do print( k, v ) end
	--Sleep( 2000 )
end

function main()
	local can232DevComm = DeviceComm.new( "Audi_B8.xml" )
	print( "Name:", can232DevComm:GetName() )
	--print( "-- CAN DeviceComm Object table" )
	--for k, v in pairs( devComm ) do print( "CAN devComm."..k, v ) end

	--print( "-- CAN232 UserSettings" )
	local can232Settings = can232DevComm:GetDefaultSettings( "CAN232" )
	--can232Settings.Port = "COM1"

	can232DevComm:Initialize( "CAN232", can232Settings )

	print( "-- DeviceComm Initialized" )
	-- ------------------------------------------------------------------------
	--	CAN Stuff
	-- ------------------------------------------------------------------------

	-- Read ECOutputState
	CallRead( can232DevComm, "ECOutputState" )

	-- Do Read DTC's
	CallDo( can232DevComm, "ReadDTCs" )

	local HBStatusId = can232DevComm:Listen( "HBStatus", OnHBStatus )

	Sleep( 2000 )

	local speedCmd = can232DevComm["Speed"]
	speedCmd.In["Speed"] = 10000
	--local speedID = can232DevComm:Broadcast( speedCmd )
	local speedID = can232DevComm:Broadcast( "Speed" )

	Sleep( 10000 )
	--for i = 1, 100000 do print( i ) end

	can232DevComm:StopPeriodic( HBStatusId )
	can232DevComm:StopPeriodic( speedID )

	print( "-- Shutting down the DeviceComm object" )
	can232DevComm:Shutdown()
end

main()
