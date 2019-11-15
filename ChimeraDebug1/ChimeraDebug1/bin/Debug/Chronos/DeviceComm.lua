--- DeviceComm Modifications.
-- Chronos hooks into certain DeviceComm facilities to provide more information in reports and to control error handling.<br/>
-- <b>This module is not activated until you require "gScripted".</b>
module( "Chronos.DeviceComm", package.seeall )

local function modDeviceComm()
	--- DeviceComm modifications
	-- @class table
	-- @name DeviceComm
	-- @field Do A wrapper around DeviceComm:Do(); if the command fails, the current test case fails.
	-- @field Write A wrapper around DeviceComm:Write(); if the command fails, the current test case fails.
	-- @field Read A wrapper around DeviceComm:Read(); if the command fails, the current test case fails.
	-- @field FailDo A wrapper around DeviceComm:Do() that expects the command to fail; if the command succeeds, the current test case fails.
	-- @field FailWrite A wrapper around DeviceComm:Write() that expects the command to fail; if the command succeeds, the current test case fails.
	-- @field FailRead A wrapper around DeviceComm:Read() that expects the command to fail; if the command succeeds, the current test case fails.
	local oldDevCommNew = DeviceComm.new

	function DeviceComm.new( commandSet )
		local devComm = oldDevCommNew( commandSet )
		local passFunctions = {
			Do = devComm.Do,
			Read = devComm.Read,
			Write = devComm.Write
		}
		local failFunctions = {
			FailDo = devComm.Do,
			FailRead = devComm.Read,
			FailWrite = devComm.Write
		}
		local getAction = function( mode, ... )
			local args = { ... }
			local action = ""
			if type( args[2] ) == "string" then
				action = mode .. "( " .. args[2]
				if args[3] then
					action = action .. ", " .. ToString( args[3] )
				end
			action = action .. " )"
			else
				action = mode .. "( " .. ToString( ( args[2] or {} ).Name )
				if mode == "Do" or mode == "FailDo" then
					action = action .. ", " .. ToString( ( args[2] or {} ).In )
				elseif mode == "Write" or mode == "FailWrite" then
					action = action .. ", " .. ToString( ( args[2] or {} ).Mem )
				end
				action = action .. " )"
			end
			return action
		end
		for k, v in pairs( passFunctions ) do
			devComm[k] = function( ... )
				Chronos.Actions.AddAction( getAction( k, ... ) )
				return v( ... )
			end
		end
		for k, v in pairs( failFunctions ) do
			devComm[k] = function( ... )
				Chronos.Actions.AddAction( getAction( k, ... ) )
				local okay, err = pcall( v, ... )
				if okay then
					Chronos.Actions.AddFailure( "Expected command to fail, but command succeeded." )
				else
					return err
				end
			end
		end
		return devComm
	end
end

if package.loaded.gScripted then
	modDeviceComm()
end

local old_require = require

function _G.require( name, ... )
	local loaded = package.loaded[ name ]
	local r = old_require( name, ... )
	if not loaded and name == "gScripted" then
		modDeviceComm()
	end
	return r
end
