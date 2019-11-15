-- ----------------------------------------------------------------------------
--
--	DevicesExplorer - A tool to show and document methods that are available in
--					  in the DeviceComm library.
--
--	Author:		Ryan Pusztai <ryan.pusztai@gentex.com>
--	Date:		11/10/2008
--
--
-- ----------------------------------------------------------------------------
require( "gScripted" )
require( "wx" )

-- Global variables -----------------------------------------------------------
--
appName					= "DevicesExplorer"
appVersion				= "2.00"
dialog					= nil -- the wxDialog main toplevel window
xmlResource				= nil -- the XML resource handle
devComm					= nil

-- CHECK VERSION -------------------------------------------------------------
--
if gScripted.version < 2.0 then
    -- Do 0.9 specific stuff.
	wx.wxMessageBox( "gScripted v"..gScripted.version.." found. Only gScripted version 2.0+ is supported.", "Error Loading gScripted v2.0+" )
	error( "gScripted v"..gScripted.version.." found. Only gScripted version 2.0+ is supported." )
end

-- HELPER FUNCTIONS -----------------------------------------------------------
--
-- return the path part of the currently executing file
function GetExePath()
    local function findLast(filePath) -- find index of last / or \ in string
        local lastOffset = nil
        local offset = nil
        repeat
            offset = string.find(filePath, "\\") or string.find(filePath, "/")

            if offset then
                lastOffset = (lastOffset or 0) + offset
                filePath = string.sub(filePath, offset + 1)
            end
        until not offset

        return lastOffset
    end

    local filePath = debug.getinfo(1, "S").source

    if string.byte(filePath) == string.byte('@') then
        local offset = findLast(filePath)
        if offset ~= nil then
            -- remove the @ at the front up to just before the path separator
            filePath = string.sub(filePath, 2, offset - 1)
        else
            filePath = "."
        end
    else
        filePath = wx.wxGetCwd()
    end

    return filePath
end

function InitializeDialog()
	-- Available Hardware classes
	for _, hardware in ipairs( DeviceComm.GetAvailableHardwareTypes() ) do
		availableHardwareListBox:Append( hardware )
	end
end

function BuildPrototype( commandName )
	if devComm then
		local prototype = ""
		local outParams = ""
		local inParams = ""
		local cmd = devComm[commandName]

		-- Out parameters
		for name, value in pairs( cmd.Out ) do
			outParams = cmd:GetParameterType( name ).." "..name..", "..outParams --.."["..value.."]".." "
		end
		--Remove the trailing ', '.
		outParams = outParams:sub( 1, outParams:len() - 2 )

		-- In parameters
		for name, value in pairs( cmd.In ) do
			inParams = cmd:GetParameterType( name ).." "..name..", "..inParams --.."["..value.."]".." "
		end
		--Remove the trailing ', '.
		inParams = inParams:sub( 1, inParams:len() - 2 )

		-- put the pieces together.
		if outParams:len() > 0 then
			prototype = outParams.." = "..commandName.."("..inParams..")"
		else
			prototype = commandName.."("..inParams..")"
		end

		return prototype
	end
end

-- EVENT HANDLERS -------------------------------------------------------------
--
-- Handle the quit button event
function OnQuit( event )
    event:Skip()

    dialog:Show(false)
    dialog:Destroy()
end

--
function OnAvailableHardwareSelected( event )
	wx.wxMessageBox( "Available Hardware Clicked!" )
end

--
function OnAvailableCommandsSelected( event )
	cmdSelected = availableCommandsListBox:GetStringSelection()
	-- Show the prototype
	local prototype = BuildPrototype( cmdSelected )
	commandPrototypeTxtCtrl:SetValue( prototype )
end

--
function OnCommandSetFileChanged( event )
	local path = event:GetPath()
	devComm = DeviceComm.new( path )

	local cmdNames = devComm:GetAllCommands()

	-- Clear the available commands list box.
	availableCommandsListBox:Clear()
	commandPrototypeTxtCtrl:Clear()

	-- Available Commands and their prototypes in the RevComm Command Set
	for _, name in ipairs( cmdNames ) do
		availableCommandsListBox:Append( name )
	end

	availableCommandsListBox:Enable( true )
	commandPrototypeTxtCtrl:Enable( true )
end

-- APPLICATION GUI ----------------------------------------------------
--
local xrcContents =
[=[
<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<resource xmlns="http://www.wxwindows.org/wxxrc" version="2.3.0.1">
	<object class="wxDialog" name="DevicesExplorerDialog">
		<style>wxCAPTION|wxCLOSE_BOX|wxDIALOG_NO_PARENT|wxMAXIMIZE_BOX|wxMINIMIZE_BOX|wxRESIZE_BORDER|wxSYSTEM_MENU</style>
		<title>DevicesExplorer v2.00</title>
		<centered>1</centered>
		<object class="wxBoxSizer">
			<orient>wxHORIZONTAL</orient>
			<object class="sizeritem">
				<option>1</option>
				<flag>wxALL|wxEXPAND</flag>
				<border>5</border>
				<object class="wxStaticBoxSizer">
					<orient>wxVERTICAL</orient>
					<label>CommandSet Details</label>
					<object class="sizeritem">
						<option>0</option>
						<flag>wxRIGHT|wxLEFT</flag>
						<border>5</border>
						<object class="wxStaticText" name="m_staticText1">
							<label>Loaded CommandSet</label>
						</object>
					</object>
					<object class="sizeritem">
						<option>0</option>
						<flag>wxEXPAND|wxBOTTOM|wxRIGHT|wxLEFT</flag>
						<border>5</border>
						<object class="wxFilePickerCtrl" name="m_loadedCommandSetFilePicker">
							<value></value>
							<message>Select a commandset</message>
							<wildcard>*.*</wildcard>
							<style>wxFLP_CHANGE_DIR|wxFLP_DEFAULT_STYLE</style>
						</object>
					</object>
					<object class="sizeritem">
						<option>0</option>
						<flag>wxRIGHT|wxLEFT</flag>
						<border>5</border>
						<object class="wxStaticText" name="m_staticText2">
							<label>Available Commands</label>
						</object>
					</object>
					<object class="sizeritem">
						<option>1</option>
						<flag>wxBOTTOM|wxRIGHT|wxLEFT|wxEXPAND</flag>
						<border>5</border>
						<object class="wxListBox" name="m_availableCommandsListBox">
							<style>wxLB_NEEDED_SB|wxLB_SINGLE|wxLB_SORT</style>
							<enabled>0</enabled>
							<content />
						</object>
					</object>
					<object class="sizeritem">
						<option>0</option>
						<flag>wxRIGHT|wxLEFT</flag>
						<border>5</border>
						<object class="wxStaticText" name="m_staticText3">
							<label>Command Prototype</label>
						</object>
					</object>
					<object class="sizeritem">
						<option>0</option>
						<flag>wxEXPAND|wxBOTTOM|wxRIGHT|wxLEFT</flag>
						<border>5</border>
						<object class="wxTextCtrl" name="m_commandPrototypeTextCtrl">
							<style>wxTE_READONLY</style>
							<enabled>0</enabled>
							<value></value>
							<maxlength>0</maxlength>
						</object>
					</object>
				</object>
			</object>
			<object class="sizeritem">
				<option>0</option>
				<flag>wxALL|wxEXPAND</flag>
				<border>5</border>
				<object class="wxStaticBoxSizer">
					<orient>wxVERTICAL</orient>
					<label>Available Hardware</label>
					<object class="sizeritem">
						<option>1</option>
						<flag>wxALL</flag>
						<border>5</border>
						<object class="wxListBox" name="m_availableHardwareListBox">
							<style>wxLB_NEEDED_SB|wxLB_SINGLE|wxLB_SORT</style>
							<enabled>0</enabled>
							<content />
						</object>
					</object>
				</object>
			</object>
		</object>
	</object>
</resource>
]=]

-- APPLICATION ENTRY POINT ----------------------------------------------------
--
function main()
	-- xml style resources (if present)
    xmlResource = wx.wxXmlResource()
    xmlResource:InitAllHandlers()

	-- load xrc from memory
	wx.wxFileSystem.AddHandler( wx.wxMemoryFSHandler() )
	wx.wxMemoryFSHandler.AddFile( "gui.xrc", xrcContents )

	xmlResource:Load( "memory:gui.xrc" )
	--xmlResource:Load( "DevicesExplorer.xrc" )

	-- Load the XRC dialog
	dialog = wx.wxDialog()
    if not xmlResource:LoadDialog( dialog, wx.NULL, appName.."Dialog" ) then
        wx.wxMessageBox("Error loading xrc resources!",
                        appName,
                        wx.wxOK + wx.wxICON_EXCLAMATION,
                        wx.NULL)
        return -- quit program
    end

	-- Setup the dialogs size
	local bestSize = dialog:GetBestSize()
	dialog:SetSize( 500, 400 )
	dialog:SetSizeHints( bestSize:GetWidth() / 2, bestSize:GetHeight() )

	-- init global wxWindow ID values
    ID_AVAILABLE_HARDWARE		= xmlResource.GetXRCID( "m_availableHardwareListBox" )
    ID_LOADED_COMMANDSET		= xmlResource.GetXRCID( "m_loadedCommandSetFilePicker" )
    ID_AVAILABLE_COMMANDS		= xmlResource.GetXRCID( "m_availableCommandsListBox" )
    ID_COMMAND_PROTOTYPE		= xmlResource.GetXRCID( "m_commandPrototypeTextCtrl" )

	-- Init controls handles
	availableHardwareListBox	= dialog:FindWindow( ID_AVAILABLE_HARDWARE ):DynamicCast( "wxListBox" )
	loadedCommandSetFilePicker	= dialog:FindWindow( ID_LOADED_COMMANDSET ):DynamicCast( "wxFilePickerCtrl" )
	availableCommandsListBox	= dialog:FindWindow( ID_AVAILABLE_COMMANDS ):DynamicCast( "wxListBox" )
	commandPrototypeTxtCtrl		= dialog:FindWindow( ID_COMMAND_PROTOTYPE ):DynamicCast( "wxTextCtrl" )

	-- Connect the event handlers
	dialog:Connect( wx.wxEVT_CLOSE_WINDOW, OnQuit )
	dialog:Connect( ID_AVAILABLE_HARDWARE,		wx.wxEVT_COMMAND_LISTBOX_SELECTED, OnAvailableHardwareSelected )
	dialog:Connect( ID_LOADED_COMMANDSET,		wx.wxEVT_COMMAND_FILEPICKER_CHANGED, OnCommandSetFileChanged )
	dialog:Connect( ID_AVAILABLE_COMMANDS,		wx.wxEVT_COMMAND_LISTBOX_SELECTED, OnAvailableCommandsSelected )

	-- Load the dailog with data
	InitializeDialog()

	dialog:Centre()
	dialog:Show( true )
end

main()

-- Call wx.wxGetApp():MainLoop() last to start the wxWidgets event loop,
-- otherwise the wxLua program will exit immediately.
wx.wxGetApp():MainLoop()
