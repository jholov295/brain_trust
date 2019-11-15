TestSuite "Expected and Actual" {
	TestCase "Test Case #1" {
		function()
			CheckEqualHex( 0x33, 0x44 )
			Check( false )
			CheckSequenceHex( { 3, 5 }, { 1, 3, 5, 7 } )
		end
	},
	
	TestCase "Test Case #2" {
		function()
			CheckNotEqualHex( 0x35, 0x88 )
			CheckWithin( 3, 10, 4 )
		end
	},
}
