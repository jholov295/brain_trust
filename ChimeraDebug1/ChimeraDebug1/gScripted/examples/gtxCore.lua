-- ---------------------------------------------------------------------------
--	gtxCore.glua - Simple example to show what is available in the gtx Core
--                library. It also shows the logging ability.
--
--	Author:		Ryan Pusztai
--	Date:		07/23/2007
--	Version:	1.00
--
--	NOTES:
--				* Requires gScripted version 1.0+
-- ---------------------------------------------------------------------------

-- INCLUDES ------------------------------------------------------------------
--
require( "gScripted" )
require( "Utils" )
require( "Debugging" )

-- DEBUGGING -----------------------------------------------------------------
--
print( "-- AVAILABLE FILEUTILS ITEMS ----------------------------------------" )
Debugging.PrintNamespaceFunctionList( "FileUtils", FileUtils )

print( "-- AVAILABLE STRINGUTILS ITEMS --------------------------------------" )
Debugging.PrintNamespaceFunctionList( "StringUtils", StringUtils )

print( "-- AVAILABLE LOGGING ITEMS ------------------------------------------" )
Debugging.PrintNamespaceFunctionList( "Logging", Logging )

print( "-- TESTING FUNCTIONS ------------------------------------------------" )
-- Testing StringUtils::StartsWith()
print( StringUtils.StartsWith( "preFix is found", "pre" ) )
print( StringUtils.StartsWith( "preFix is not found", "pres" ) )
-- Testing StringUtils::EndsWith()
print( StringUtils.EndsWith( "postFix is found", "und" ) )
print( StringUtils.EndsWith( "postFix is not found", "post" ) )
-- Testing Logging
Log( TRACE, "Trace["..TRACE.."] message logged." )
Log( WARNING, "Warning["..WARNING.."] message logged." )
Log( DEBUG, "Debug["..DEBUG.."] message logged." )
Log( SEVERE, "Severe["..SEVERE.."] error message logged." )
level, levelName = Logging.GetScriptingLogLevel()
print( "The current log level before changing it: "..levelName.."["..level.."]"  )
print( "Setting the Script engine log level to DEBUG. The old log level is: "..Logging.GetLevelName( Logging.SetScriptingLogLevel( DEBUG ) ) )
PrintLog( TRACE, "Trace["..TRACE.."] message logged." )
PrintLog( WARNING, "Warning["..WARNING.."] message logged." )
PrintLog( DEBUG, "Debug["..DEBUG.."] message logged." )
PrintLog( SEVERE, "Severe["..SEVERE.."] error message logged." )
print( "The current log level is: "..select( 2, Logging.GetScriptingLogLevel() ) )
-- Testing Threading
Sleep( 1500 )
-- Testing FileUtils
print( FileUtils.IsReadOnly( "gtxCore.lua" ) )
print( FileUtils.ReadFileIntoString( "gtxCore.lua" ) )

print( "" )
Utils.Prompt( "Press <Enter> to continue..." )
