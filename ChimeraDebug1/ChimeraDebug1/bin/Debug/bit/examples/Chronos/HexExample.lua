TestSuite "My Hex Suite" {
	TestCase "Use ToHexString to format values as hex" {
		function()
			AddAction( "The magic number is: " .. ToHexString( 0x1234, 4 ) ) -- The second argument is how many digits to show.
		end
	},
	
	TestCase "Use StartHex/EndHex to form long strings" {
		function()
			AddAction( "I want to print this in decimal: " .. 42 .. " but these in hex: " .. StartHex() ..
				0x3A .. ", " .. 0x21 .. ", and " .. 0xFF .. EndHex( 2 ) ) -- The argument to EndHex() is how many digits to show.
		end
	},
	
	TestCase "Use *Hex version of checks" {
		function()
			CheckEqualHex( 0x22, 0x33 ) -- Actions and failures coming from these checks will be shown in hex,
																	-- with the number of digits specified in the configuration file
		end
	}
}
