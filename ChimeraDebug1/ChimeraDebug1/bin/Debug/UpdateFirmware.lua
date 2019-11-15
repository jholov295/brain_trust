--[[ Gets new firmware from a URL.

	The URL can be local:
	UpdateFirmware("C:/ChimeraFirmware/chimera.hex")
	or it can be on the LAN/WWW:
	UpdateFirmware("http://eeweb/svn/testers/deployment/firmware/Chimera/chimera.hex").

	This script is triggered by a source code change, so we will have a new hex file and
	don't need to do a version comparison.  Flashing new firmware every time is annoying for
	testing when no firmware is available, so I added a prompt.

	A possible bug in the works is problem of updated protocols. When gScripted is updated
	to the new protocol, it complains that the Chimera is using the old one, even if the
	new hex file has the new protocol. If the new Chimera firmware is flashed before gScripted
	is updated, it will fail to communicate afterwards, and all tests will fail.
-]]
function UpdateFirmware(URL)
	if (type(URL) ~= "string") then
		error("URL must be a string.")
		exit()
	end

	print("Updating firmware from:\n", URL)

	--Set up DCs
	testerCommandSettings, DUTCommandSettings,
	testerUserSettings, DUTUserSettings = getDefaultSettings()
	testerUserSettings.ChimeraCan.IP = "10.1.1.3"
	setModifiedSettings("ChimeraCan",
						testerCommandSettings, DUTCommandSettings,
						testerUserSettings, DUTUserSettings)
	print("Initialized Chimera DCs")

	--Get old versions
	local resultTester = testerDC:Do( "GetVersion" )
	local resultDUT = DUTDC:Do( "GetVersion" )
	print("Current Versions are:\n\tTester: " .. resultTester["Version"] .. "\n\tDUT: " .. resultDUT["Version"])

	--Update versions
	print("Flashing firmware.  Please wait (may take up to 60 seconds) ...")

	-- Must convert between string and U8 Vector for UpdateFirmware hardware command
	-- Commands only deal in numbers and arrays.
	-- For example, the deployment firmware at:
	-- "http://eeweb/svn/testers/deployment/firmware/Chimera/chimera.hex"
	-- must be
	-- {, 0x68, 0x74, 0x74, 0x70, 0x3A, 0x2F, 0x2F, 0x65, 0x65, 0x77, 0x65 ... 0x78}
	local URL_V = {}

	for i = 1, string.len(URL) do
		URL_V[i] = string.byte(URL, i)
	end

	testerDC:Do("UpdateFirmware", {Path = URL_V})
	print("Updated tester.")
	DUTDC:Do("UpdateFirmware", {Path = URL_V})
	print("Updated DUT.")

	sleep(1)

	--Get new versions
	local resultTester = testerDC:Do( "GetVersion" )
	local resultDUT = DUTDC:Do( "GetVersion" )

	print("Current Versions are:\n\tTester: " .. resultTester["Version"] .. "\n\tDUT: " .. resultDUT["Version"])

end
