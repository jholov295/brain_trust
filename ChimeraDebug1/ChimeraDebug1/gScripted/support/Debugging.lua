---	Helper functions that can be used to help debug Lua	scripts. It has some
--	namespace and table dumping functions.
--
--	@name		cllib.Debugging
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
module( "Debugging", package.seeall )

-- DEBUGGING FUNCTIONS --------------------------------------------------------
--

---	Recursively dumps the contents of a table.
--	@param atable Table to dump.
--	@param prefix [OPT] String to prefix to each item in the table.
--	@param tablelevel Don't use it. Only used for the recursive call.
function TableDump( atable, prefix, tablelevel )
	assert( type( atable ) == "table", "Expected a table" )
	prefix = prefix or ""
	if tablelevel == nil then tablelevel = "" end

	print( prefix.."-Dumping Table "..tablelevel, atable )
	prefix = prefix.."  "
	local n = 0

	for k, v in pairs( atable ) do
		n = n + 1
		print( prefix..n..":", tablelevel.."["..k.."]", v )
		if type( v ) == "table" then
			TableDump( v, prefix.."  ", tablelevel.."["..k.."]" )
		end
	end
end

---	Prints out a list of available functions and data in a specified namespace.
--	@param name String of the name of the table <em>tbl</em> you are listing.
--	@param tbl Table that you want to list all the functions and data.
function PrintNamespaceFunctionList( name, tbl )
	assert( type( name ) == "string", "Expected a string" )
	assert( type( tbl ) == "table", "Expected a table" )
	print( "Available functions/data in the '" .. name .. "' namespace:" )
	for k, v in pairs( tbl ) do
		if type( tbl[k] ) == "function" then
			print( name .. "." .. k .. "()" )
		else
			print( name .. "." .. k .. " = " .. tostring(v) )
		end
	end
end
