---	Helper functions that are general helper functions to Lua.
--
--	@name		cllib.Utils
--	@author		<a href="mailto:ryan.pusztai@gentex.com">Ryan Pusztai</a>
--	@release	1.00 <09/14/2007>
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
module( "Utils", package.seeall )

-- UTILS FUNCTIONS -----------------------------------------------------------
--

---	Prompts user showing <em>message</em> and then take what is typed as the return.
--	@param message The message to show the user before they input the data.
--	<h3>Note:</h3>
--	<ul>This requires the user to press 'ENTER' to allow the program execution
--       to continue.</ul>
function Prompt( message )
	-- Show the message.
	print( message )
	-- Open the standard in for reading.
	local stdinHandle = io.input( io.stdin )
	-- Read the value from the user after they hit 'Enter'.
	local ret = stdinHandle:read()
	-- close the file handle
	stdinHandle:close()

	return ret
end
