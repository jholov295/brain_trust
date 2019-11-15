require "Chronos"
require "Chronos.Auto"
require "gScripted"

TestSuite "Auto-Generated" {
	Setup = function()
		deviceComm = DeviceComm.new( "C:/code/commandsets/Audi_KWP.cmdset" )
		deviceComm:Initialize( "Can232", { Port = "COM3" } )
	end,
	
	Auto "C:/code/commandsets/Audi_KWP.cmdset" {
		"ALS .*",
		
		Setup = function()
			print "Setup"
		end,
		
		Teardown = function()
			print "Teardown"
		end,
		
		Test = function( command )
			local results = AutoRun( deviceComm, command )
			AutoCheck( deviceComm, results )
		end
	}
}
