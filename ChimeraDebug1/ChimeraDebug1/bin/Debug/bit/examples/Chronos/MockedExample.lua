TestSuite "My Test Suite" {
	Setup = function()
		deviceComm = {
			Do = function( self, cmd )
				Chronos.Actions.AddAction( "Do( " .. cmd .. " )" )
				return {
					Out = {
						SomeArray = { 0, 1, 2, 3, 4 }
					}
				}
			end,
			
			Read = function( self, cmd )
				Chronos.Actions.AddAction( "Read( " .. cmd .. " )" )
				return {
					Mem = {
						ImportantValue = 8
					}
				}
			end
		}
	end,

	TestCase "Validates MyCommand" {
		function()
			local result = deviceComm:Do( "MyCommand" )
			CheckSequence( { 1, 2, 3 }, result.Out.SomeArray )
		end
	},

	TestCase "Validates MyOtherCommand" {
		function()
			local result = deviceComm:Read( "MyOtherCommand" )
			CheckEqual( 5, result.Mem.ImportantValue, "Important value was not 5!" )
		end
	}
}
