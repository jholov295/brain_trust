
if not _SETUP then
	_SETUP = true

	-- Clear the ARP cache silently.
	-- This is a POSIX command; so it is semi-portable.
	os.capture("arp -d 10.1.1.2")
	os.capture("arp -d 10.1.1.3")


	--[[ Initialize globals --]]
	function getDefaultSettings()
		--Create DeviceComm objects with command settings
		testerDC = DeviceComm.new( CommandSetPath )
		DUTDC = DeviceComm.new( CommandSetPath )
		--Set up for defaults
		testerCommandSettings = tcopy(DefaultCommandSettings)
		DUTCommandSettings = tcopy(DefaultCommandSettings)
		--Initialize DeviceComm objects with user settings
		--Create tables from default
		testerUserSettings = tcopy(DefaultUserSettings)
		DUTUserSettings = tcopy(DefaultUserSettings)
		return 	testerCommandSettings, DUTCommandSettings,
				testerUserSettings, DUTUserSettings
	end
	--[[Sets the settings to the initialized DeviceComm objects. --]]
	function setModifiedSettings(	protocolStr,
							testerCommandSettings, DUTCommandSettings,
							testerUserSettings, DUTUserSettings )

		--Assign command settings to DeviceComm objects
		testerDC:SetProtocolSettings("Commands", testerCommandSettings)
		DUTDC:SetProtocolSettings("Commands", DUTCommandSettings)

		--Assign user settings to DeviceComm objects
		testerDC:Initialize(protocolStr, testerUserSettings[protocolStr])
		DUTDC:Initialize(protocolStr, DUTUserSettings[protocolStr])
	end
end
