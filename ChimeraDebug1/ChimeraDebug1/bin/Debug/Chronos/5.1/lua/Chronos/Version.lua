local workingCopyDate = "2011/06/13 12:09:49"
local year, month = workingCopyDate:match( "(%d%d)/(%d%d)/%d+" )
Chronos.Version = string.format( "%02i.%02i.4810", year, month )
