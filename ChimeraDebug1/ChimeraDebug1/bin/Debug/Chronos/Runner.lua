_G.CHRONOS_RUN_MANUALLY = true

print( "" ) -- Some elbow room

local lapp = require( "pl.lapp" )

local lappString = [[
Run the specified Chronos suites and generate reports.

	-r,--results																Saves results to disk.
	-c,--config	 (default ChronosConfig.xml)	 Specifies the Chronos config file to use.
	-s,--suite		(default all)								 A single test suite to run, by name.
	-t,--case		 (default all)								 A single test case to run, by name, if only running one test suite.
	-m,--teamcity															 Output using TeamCity format.
	-v,--version																Print the Chronos version.
	<files...>		(default none)								Paths/patterns/directories of Chronos test files to run.
]]

local args = lapp( lappString )

package.path = package.path .. ";./?/init.lua"

require( "Chronos" )

if args.version then
	print( Chronos.Version )
	return
end

if #args.files < 1 or args.files[ 1 ] == "none" then
	print( "Missing required parameter: files\n" )
	print( lappString )
	error()
end

local okay, err = pcall( function()
	Chronos.CurrentConfig = Chronos.LoadConfig( args.config )
end )
if not okay then
	print( err )
	print( "Using default configuration (no reports)\n" )
	Chronos.CurrentConfig = Chronos.Config.Default
end
Chronos.CurrentTestAccumulator = Chronos.TestAccumulator.new()
if args.teamcity then
	Chronos.CurrentInfoPrinter = Chronos.TeamCityInfoPrinter.new()
else
	Chronos.CurrentInfoPrinter = Chronos.InfoPrinter.new()
end

for _, file in ipairs( args.files ) do
	local result, message = pcall( dofile, file )
	if not result then
		print( message )
		return
	end
end

local results = nil

if args.suite ~= "all" then
	local testSuite = nil
	for _, ts in ipairs( Chronos.CurrentTestAccumulator.TestSuites ) do
		if ts:GetName() == args.suite then
			testSuite = ts
		end
	end
	if not testSuite then
		error( "Test suite \"" .. args.suite .. "\" not found" )
	end
	if args.case ~= "all" then
		local testCase = testSuite.TestCases[ args.case ]
		if not testCase then
			error( "Test case \"" .. args.case .. "\" not found" )
		end
		results = Chronos.RunSuiteCase( testSuite, testCase, args.results )
	else
		results = Chronos.Run( { testSuite }, args.results )
	end
else
	results = Chronos.RunAccumulated( args.results )
end

local config = Chronos.CurrentConfig

if #config.Reports > 0 then
	print( "" ) -- Just to make the output more spaced out.
	for _, report in ipairs( config.Reports ) do
		local result, message = pcall( function()
			print( "Rendering " .. ( report.OutputPath or "" ) )
			Chronos.RenderReport( results, report.TemplatePath, report.OutputPath )
		end )
		if not result then
			print( message )
		end
	end
	print( "" )
end

if results.Failed then
	print( "Test run failed" )
	error()
end
