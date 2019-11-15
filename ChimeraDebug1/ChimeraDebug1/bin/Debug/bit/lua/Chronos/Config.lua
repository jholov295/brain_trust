--- Defines configuration settings for Chronos command-line execution.
-- <pre class="example">
-- &lt;Chronos&gt;<br/>
-- &nbsp; &lt;HexDigits&gt;2&lt;/HexDigits&gt;<br/>
-- &nbsp; &lt;Reports&gt;<br/>
-- &nbsp; &nbsp; &lt;Report&gt;<br/>
-- &nbsp; &nbsp; &nbsp; &lt;TemplatePath&gt;<br/>
-- &nbsp; &nbsp; &nbsp; &nbsp; MyTemplates/AwesomeTemplate.lhtml<br/>
-- &nbsp; &nbsp; &nbsp; &lt;/TemplatePath&gt;<br/>
-- &nbsp; &nbsp; &nbsp; &lt;OutputPath&gt;<br/>
-- &nbsp; &nbsp; &nbsp; &nbsp; MyReports/AwesomeReport.html<br/>
-- &nbsp; &nbsp; &nbsp; &lt;/OutputPath&gt;<br/>
-- &nbsp; &nbsp; &lt;/Report&gt;<br/>
-- &nbsp; &nbsp; &lt;Report&gt;<br/>
-- &nbsp; &nbsp; &nbsp; &lt;TemplatePath&gt;<br/>
-- &nbsp; &nbsp; &nbsp; &nbsp; MyTemplates/EquallyAwesomeTemplate.lhtml<br/>
-- &nbsp; &nbsp; &nbsp; &lt;/TemplatePath&gt;<br/>
-- &nbsp; &nbsp; &nbsp; &lt;OutputPath&gt;<br/>
-- &nbsp; &nbsp; &nbsp; &nbsp; MyReports/EquallyAwesomeReport.html<br/>
-- &nbsp; &nbsp; &nbsp; &lt;/OutputPath&gt;<br/>
-- &nbsp; &nbsp; &lt;/Report&gt;<br/>
-- &nbsp; &lt;/Reports&gt;<br/>
-- &lt;/Chronos&gt;<br/>
-- </pre>
module( "Chronos.Config", package.seeall )

---
-- @name Chronos.Config
-- @class table
-- @field Reports An array of report definitions

---
-- @name Report
-- @class table
-- @field TemplatePath The path to the desired template file
-- @field OutputPath The path to the desired output location

--- Contains default configuration settings.
Default = {
	Reports =
	{
	}
}

--- Retrieves a value from the loaded configuration file.
-- @param name The name of the value.
-- @return The loaded value, if any.
function GetValue( name )
	if Chronos.CurrentConfig then
		return Chronos.CurrentConfig[ name ]
	end
	return nil
end

--- Loads a Chronos configuration file in XML format.
-- @param configPath Path to the configuration file.
-- @return A parsed Chronos configuration as a table.
function Chronos.LoadConfig( configPath )
	local success, ret = pcall( function()
		local config =
		{
			HexDigits = 8,
			Reports =
			{
			}
		}
		local configXml = XML( pl.utils.readfile( configPath ) )
		if not configXml then
			error( "Couldn't load config file " .. configPath, 2 )
		end
		configXml = configXml.Chronos
		if not configXml then
			error( "Config file did not contain Chronos root node.", 2 )
		end
		local hexDigitsXml = configXml.HexDigits
		if hexDigitsXml and hexDigitsXml[ "$" ] and tonumber( hexDigitsXml[ "$" ] ) then
			config.HexDigits = tonumber( hexDigitsXml[ "$" ] )
		end
		local reportsXml = configXml.Reports.Report
		if not reportsXml or not reportsXml[ 1 ] then
			reportsXml = { reportsXml }
		end
		for _, reportXml in ipairs( reportsXml ) do
			local templatePathXml = reportXml.TemplatePath
			local outputPathXml = reportXml.OutputPath
			if not templatePathXml or not outputPathXml then
				error( "Report did not contain TemplatePath or OutputPath", 2 )
			end
			local templatePath = templatePathXml[ "$" ]
			local outputPath = outputPathXml[ "$" ]
			table.insert( config.Reports, { TemplatePath = templatePath, OutputPath = outputPath } )
		end
		return config
	end )
	if success then
		return ret
	end
	error( "Error loading config file " .. tostring( configPath ) .. " (" .. ret .. ")", 2 )
end
