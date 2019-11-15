if _LEXECUTOR then
    -- Specialized prompt function for Lexecutor
    -- Included file is *not* Utilities.lua, which is local to the project.
    -- It's C:\Program Files\Lua\5.1\lua\Utils.lua instead.
	require( "Utils" )
end

dofile("C:/Users/josh.holovka/source/repos/ChimeraDebug1/ChimeraDebug1/bin/Debug/LoadLibs.lua")

function run()

	--os.execute("ChimeraDebug.exe")

	dofile("UpdateFirmware.lua")
	if _TEAMCITY then
        -- This is where the firmware is located after a new build
        -- on the TeamCity server.
        -- Rename deployment_hex/ to hex/ to simulate.
		UpdateFirmware("./hex/chimera.hex")
	else
		ans = "no"

		if yes(ans) then
			url = prompt('Enter the URL of the desired hex file, or leave blank to use the deployed firmware.')
			if url == "" then
				-- This is the location of the deployed firmware.
				UpdateFirmware("http://eeweb/svn/testers/deployment/firmware/Chimera/chimera.hex")
				-- We want to update from the most recently built firmware.
				-- This will come from the project source at http://eeweb/svn/tools/projects/Chimera/
				--UpdateFirmware("C:/ChimeraFirmware/chimera.hex")
			else
                assert(type(url) == "string")
				UpdateFirmware(url)
			end
		else
			print("Firmware will not be updated.")
			sleep(.4)
		end
	end

	if _TEAMCITY then
		os.execute("Chronos.bat --teamcity " .. TestsPrefix .. "BasicTests.lua" .. " " .. TestsPrefix .. "AdvancedTests.lua")
	elseif _LEXECUTOR then
		os.execute("Chronos.bat " .. TestsPrefix .. "BasicTests.lua")
	else --Lua trigger
		basic= true
		advan = false

		print("Starting Chronos....")
		sleep(.4)
		--TODO: Get URL of other tests desired by user here, and add them to the string.
		if basic and advan then
			os.execute("Chronos.bat " .. TestsPrefix .. "BasicTests.lua" .. " " .. TestsPrefix .. "AdvancedTests.lua")
		elseif basic then
			os.execute("Chronos.bat " .. TestsPrefix .. "BasicTests.lua")
		elseif advan then
			os.execute("Chronos.bat " .. TestsPrefix .. "AdvancedTests.lua")
		else
			print("No tests selected. Exiting....")
			sleep(1.5)
		end
	end
end

function main()

	if _LEXECUTOR then
		lExecutor.ClearLog()
	end

	run()
end

if (not _LEXECUTOR)	then
	main()
end
