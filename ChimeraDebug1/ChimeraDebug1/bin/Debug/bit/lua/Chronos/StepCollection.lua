module( "Chronos.StepCollection", package.seeall )

Chronos.StepCollection.__index = Chronos.StepCollection

function Chronos.StepCollection.new()
	local t =
	{
		States = { }
	}
	return setmetatable( t, Chronos.StepCollection )
end

function Chronos.StepCollection:Add( state, step )
	state = state or "Idle"
	table.insert( self, step )
	table.insert( self.States, state )
end

function Chronos.StepCollection:__index( key )
	if rawget( Chronos.StepCollection, key ) then
		return rawget( Chronos.StepCollection, key )
	end
	local stepType = ""
	if key == "Actions" then
		stepType = "Action"
	elseif key == "Failures" then
		stepType = "Failure"
	end
	if key == "Actions" or key == "Failures" then
		local steps = Chronos.StepCollection.new()
		for i, step in ipairs( self ) do
			if step.Type == stepType then
				steps:Add( self.States[ i ], step )
			end
		end
		return steps
	end
	if pl.tablex.find( { "Idle", "Setup", "EachSetup", "EachTeardown", "Teardown", "Test" }, key ) then
		local steps = Chronos.StepCollection.new()
		for i, state in ipairs( self.States ) do
			if state == key and self[ i ] then
				steps:Add( state, self[ i ] )
			end
		end
		return steps
	end
end

