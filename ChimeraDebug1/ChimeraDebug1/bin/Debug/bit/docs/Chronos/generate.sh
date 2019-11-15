#!/bin/sh
#
# Generates the documentation for Chronos using Posix.
#

cd ..
lua docs/luadoc_start.lua Chronos/Runner.luadoc Chronos/LuaPP.lua Chronos/init.lua Chronos/Csv.lua Chronos/Html.lua Chronos/Auto/init.lua Chronos/Actions/init.lua Chronos/Actions/Checks.lua Chronos/Actions/Interactive.lua Chronos/Actions/Traceability.lua Chronos/Actions/Utilities.lua Chronos/Actions/MakeCheck.lua Chronos/Config.lua Chronos/DeviceComm.lua Chronos/DSL.lua Chronos/Hex.lua Chronos/DebugInfoPrinter.lua Chronos/TeamCityInfoPrinter.lua Chronos/Failure.lua Chronos/Action.lua Chronos/InfoPrinter.lua Chronos/TestAccumulator.lua Chronos/TestCase.lua Chronos/TestCaseRecorder.lua Chronos/TestCaseResults.lua Chronos/TestRunRecorder.lua Chronos/TestRunResults.lua Chronos/TestSuite.lua Chronos/TestSuiteRecorder.lua Chronos/TestSuiteResults.lua Chronos/Time.lua -d docs -nofiles
cd docs

#lua luadoc_start.lua -nofiles ../Chronos/*.luadoc ../Chronos/*.lua ../Chronos/Auto/*.lua ../Chronos/Actions/*.lua
