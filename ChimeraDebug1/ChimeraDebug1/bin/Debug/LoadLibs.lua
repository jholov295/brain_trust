--This version of the LoadLibs.lua file resides in the same directory as the libraries
if not _LOADLIBS then
	_LOADLIBS = true

	--The next two lines allow running in any directory by
	--placing this file in that directory and changing them to the
	--directory containing the tests and the directory containing the
	--'libraries'.
	TestsPrefix = "Tests/"
	LibsPrefix = "./"

	require ("gScripted")
	--package.path=package.path ..";C:/Users/josh.holovka/source/repos/5.1/lua/Chronos"
	--require ("chronos")

	dofile(LibsPrefix .. "Utilities.lua")
	dofile(LibsPrefix .. "Setup.lua")

	dofile(LibsPrefix .. "DefaultSettingsTables.lua")

	-- Path to cmdset which contains send/recieve functions
	CommandSetPath = LibsPrefix .. "ChimeraTester.cmdset"
end