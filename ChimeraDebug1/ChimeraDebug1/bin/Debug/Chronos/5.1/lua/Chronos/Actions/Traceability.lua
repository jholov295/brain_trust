--- Functions for injecting information into test cases for reporting purposes.
module( "Chronos.Actions.Traceability", package.seeall )

--- Adds requirements entries for the current test case.
-- For use in requirements tracking.
-- <b>This function is exported into the global table.</b>
-- @usage <pre>TestCase "My Test Case"<br/>
-- {<br/>
-- &nbsp; function()<br/>
-- &nbsp; &nbsp; TrackRequirements( "SR-44", "SR-50" )<br/>
-- &nbsp; &nbsp; -- Continue test case<br/>
-- &nbsp; end<br/>
-- }<br/></pre>
-- @param ... A list of requirements to add.
function TrackRequirements( ... )
	local function dissect( requirement )
		local req, comment = string.match( requirement, "(.*): ?(.*)" )
		return { Requirement = req or requirement, Comment = comment }
	end
	local requirements = pl.tablex.imap( dissect, { ... } )
	local recorder = Chronos.GetActiveRecorder()
	if recorder then
		recorder.Results.Requirements = recorder.Results.Requirements or { }
		for _, requirement in ipairs( requirements ) do
			table.insert( recorder.Results.Requirements, requirement )
		end
	end
end

--- Sets the source code files covered by the current test case.
-- For use in embedded software integration testing.
-- <b>This function is exported into the global table.</b>
-- @usage <pre>TestCase "My Test Case"<br/>
-- {<br/>
-- &nbsp; function()<br/>
-- &nbsp; &nbsp; TrackSources( "foo.bar" )<br/>
-- &nbsp; &nbsp; -- Continue test case<br/>
-- &nbsp; end<br/>
-- }<br/></pre>
-- @param ... A list of source files to add.
function TrackSources( ... )
	local sources = { ... }
	local recorder = Chronos.GetActiveRecorder()
	if recorder then
		recorder.Results.Sources = recorder.Results.Sources or { }
		for _, source in ipairs( sources ) do
			table.insert( recorder.Results.Sources, source )
		end
	end
end

GlobalExport( "TrackRequirements", "TrackSources" )
