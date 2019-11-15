---	Helper functions that create a simple log file.
--
--	@name		cllib.SimpleLogging
--	@author		<a href="mailto:ryan.pusztai@gentex.com">Ryan Pusztai</a>
--	@release	1.00 <09/05/2007>
--
--	<h3>Note:</h3>
--	<ul>
--	This module is part of <em>cllib</em> (<em>Common Lua Library</em>). You will need extra
--	files to use these functions. See 'Usage:' section for more information.
--	</ul>
--
--	<h3>Usage:</h3>
--	<ul>
--	To use these scripts all you need to do is <code>require()</code> at the top of
--	the file.
--	<br />
--	This is an example of using an included module:
--		<pre class="example">require( "ModuleName" )</pre>
--	This is an example of calling a function in that module:
--		<pre class="example">ModuleName.CoolFunction( parameter1, parameter2 )</pre>
--	</ul>
module( "SimpleLogging", package.seeall )

-- LOGGING FUNCTIONS --------------------------------------------------------
--

---	Log information to a file. The file will be in the form of
--	<code>Log_{month}_{day}_{year}.log</code>
--	@param msg String to send to the log file. This will have the date and time
--		pre-pended to the message.
function Log( msg )
	assert( type( msg ) == "string", "Expected a string" )
	local d = os.date( "*t" )
	local oFile = io.open( "Log_"..d.month.."-"..d.day.."-"..d.year..".log", "a+" )
	oFile:write( os.date(), "\t", msg, "\n" )
	oFile:close()
end
