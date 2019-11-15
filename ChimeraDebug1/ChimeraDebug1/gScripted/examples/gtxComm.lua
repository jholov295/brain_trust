-- ---------------------------------------------------------------------------
--	gtxComm.lua - Example code to exercise the gtxComm library.
--
--	Author:		Ryan Pusztai
--	Date:		01/20/2009
--	Version:	1.04
--
--	NOTES:
--				- Use a serial loopback to get the responses correctly.
-- ---------------------------------------------------------------------------

local port = "COM1"
local baudRate = 2400


-- INCLUDES ------------------------------------------------------------------
--
require( "gScripted" )
require( "Utils" )

-- DEBUGGING -----------------------------------------------------------------
--

--for k, v in pairs( _G.SerialPort ) do print( k, v ) end
print( "Make sure you have a loopback installed on the serial port before continuing" )
Utils.Prompt( "Press <Enter> to continue..." )

-- Initialize the port.
mySerialPort = SerialPort:new()
mySerialPort:Init( port, baudRate, 8, SerialPort.ONE_STOP_BIT, SerialPort.NO_PARITY, 1000 )

-- RAW READ/WRITE Test --------------------------------------------------------
--
local messageToSend = "Hi From Lua"
mySerialPort:Write( messageToSend, messageToSend:len() )

local response = mySerialPort:Read( messageToSend:len() )
if #response > 0 then
	print( response )
else
	error( "No response found. Make sure a loopback is installed on "..port )
end

-- TRANSMIT TEST --------------------------------------------------------------
--
messageToSend = "Testing\rCarrage Return EOL\rTransmit\r"
local eolCharacter = string.byte( "\r" )
local response, isTimedOut = mySerialPort:TransmitUntilCharacter( messageToSend, #messageToSend )
while not isTimedOut do
	print( response )
	-- Read next chunk
	response, isTimedOut = mySerialPort:TransmitUntilCharacter( "", 0, eolCharacter, 0.50 )
end

-- Error on purpose.
response, isTimedOut = mySerialPort:TransmitUntilCharacter( "", 0, eolCharacter, 0.25 )
if #response > 0 then
	print( response )
else
	print( "No response found." )
end


messageToSend = "Testing\nNewLine EOL\nTransmit\n"
eolCharacter = string.byte( "\n" )
response, isTimedOut = mySerialPort:TransmitUntilCharacter( messageToSend, #messageToSend, eolCharacter )
while not isTimedOut do
	print( response )
	-- Read next chunk
	response, isTimedOut = mySerialPort:TransmitUntilCharacter( "", 0, eolCharacter, 0.50 )
end

Utils.Prompt( "Press <Enter> to continue..." )
