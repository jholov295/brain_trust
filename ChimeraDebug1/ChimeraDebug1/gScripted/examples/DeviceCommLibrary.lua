-- ---------------------------------------------------------------------------
--	DeviceCommLibrary.lua - Example code to show how to interigate the
--							DeviceComm Library.
--
--	Author:		Ryan Pusztai
--	Date:		11/11/2008
--	Version:	1.00
--
--	NOTES:
--				* Requires gScripted version 1.0+
--				* This is a simple example of a start to a gScripted sript.
--				  Replace/add your code below the "MAIN CODE" separator.
-- ---------------------------------------------------------------------------

-- INCLUDES ------------------------------------------------------------------
--
require( "gScripted" )
require( "Utils" )

-- CHECK VERSION -------------------------------------------------------------
--
if gScripted.version < 2.1 then
    -- Do 2.1 specific stuff
	error("gScripted v"..gScripted.version.." found. Only gScripted version 2.1+ is supported.")
end

if gScripted.buildNumber < 1000 then
    -- Do a finer grained version controls stuff here.
end

-- MAIN CODE -----------------------------------------------------------------
--

-- Check the package.[c]path
print( "package.path = "..package.path, "\n\n" )
print( "package.cpath = "..package.cpath, "\n\n" )

-- Check to see what versions of gScripted and libraries we are running.
print( string.format( "gScripted v%s.%02d", tostring( gScripted.version ), gScripted.buildNumber ) )
print( "gtx Library Revision: "..gtx.buildNumber )
print( "DeviceComm Library Revision: "..DeviceComm.buildNumber )

print( "-- gScripted table" )
for k, v in pairs( gScripted ) do print( "gScripted."..k, v ) end

print( "-- DeviceComm table" )
for k, v in pairs( DeviceComm ) do print( "DeviceComm."..k, v ) end

print( "-- DeviceComm available hardware" )
	for k, v in pairs( DeviceComm.GetAvailableHardwareTypes() ) do print( k, v ) end

print( "Hello World" )

--for k, v in pairs(_G) do print( "["..k.."]", v ) end

print( "Script that is loaded: ", arg[0] )
print( "Number of arguments sent to the script: ", #arg )
print( "Unpacked arguments: ", unpack( arg ) )

print( "Good-bye world" )

PrintLog( ERROR, "Good-bye cold world" )

print( "" )
--Utils.Prompt( "Press <Enter> to continue..." )
