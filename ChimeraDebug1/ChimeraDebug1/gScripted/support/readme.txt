-- Description ----------------------------------------------------------------
--

This is a location to store helper scripts. This should be a place where
functions that are useful to scripting DevIO and the Script Engine, in
general, should go.

-- Usage ----------------------------------------------------------------------
--

To use these scripts all you need to do is at the top of the file add these
lines. This will point the script engine at the common directory so that you
can load any of the helper modules.
	-- Setup where to look for includes.
	package.path = package.path..";;./?.lua;./scripts/?.lua;./scripts/default/?.lua"
	
This is an example of using an included module:
	local mod = require( "ModuleName" )
This is an example of calling a function in that module:
	mod.CoolFunction( parameter1, parameter2 )

