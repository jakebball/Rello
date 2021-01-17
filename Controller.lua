
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

--//INITIAL WINDOW SETUP

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	true,
	true,
	686,
	382,
	686,
	382
)

local toolbarButton = plugin:CreateToolbar("Rello V1"):CreateButton("Rello V1",  "A plugin designed to let you use trello in studio", "rbxassetid://4458901886")

local pluginId = "RelloVersion_V1"
local debounce = false

local modules = script.Parent.Modules
local guiElements = script.Parent.GuiElements

local informationIndex = require(modules.InformationIndex)
local commandQueue = require(modules.CommandQueue)
local trelloService = require(modules.TrelloService)

local widgetGui = plugin:CreateDockWidgetPluginGui(pluginId, widgetInfo)
widgetGui.Title = "Rello Version V1"
widgetGui.Name = "Rello V1"

local relloMainGui = guiElements["RelloV1"]
relloMainGui.Parent = widgetGui

toolbarButton.Click:Connect(function()
	widgetGui.Enabled = not widgetGui.Enabled
end)

--//RIBBON CLICK DETECTION

--[[
PAGE LAYOUT INDEXES
1 - Settings
2 - Create List
3 - Archive List
4 - Card Start Page
5 - Archive Card
6 - Create Card
7 - List Start Page
]]


local MainWindowLayout = relloMainGui.MainWindow.UIPageLayout

relloMainGui.Ribbon.Cards.MouseButton1Click:Connect(function()
	MainWindowLayout:JumpToIndex(4)
end)

relloMainGui.Ribbon.List.MouseButton1Click:Connect(function()
	MainWindowLayout:JumpToIndex(7)
end)

relloMainGui.Ribbon.Settings.MouseButton1Click:Connect(function()
	MainWindowLayout:JumpToIndex(1)
end)


local SettingsPage = relloMainGui.MainWindow.SettingsPage
local ListStartPage = relloMainGui.MainWindow.ListStartPage
local CreateListPage = relloMainGui.MainWindow.CreateListPage
local ArchiveListPage = relloMainGui.MainWindow.ArchiveListPage
local CardsStartPage = relloMainGui.MainWindow.CardsStartPage
local CreateCardPage = relloMainGui.MainWindow.CreateCardPage
local ArchiveCardPage = relloMainGui.MainWindow.ArchiveCardPage

local Status = relloMainGui.Status

if RunService:IsStudio() then
	SettingsPage.APIKey.TextBox.Text = "e227831cd0fd295cc85b6c2d26b6d05b"
	SettingsPage.BoardID.TextBox.Text = "ClQ95I4D"
	SettingsPage.Token.TextBox.Text = "f17b0f31f2d8b59869439a439b342d2afc9d3888b9649b1692802ba95e6c4ca8"
end

--//SETTINGS

SettingsPage.Save.MouseButton1Click:Connect(function()
	local APIKey_isEmpty = SettingsPage.APIKey.TextBox.Text:gsub("%s+", "") == ""
	local BoardID_isEmpty = SettingsPage.BoardID.TextBox.Text:gsub("%s+", "") == ""
	local Token_isEmpty = SettingsPage.Token.TextBox.Text:gsub("%s+", "") == ""
	
	if not APIKey_isEmpty and not BoardID_isEmpty and not Token_isEmpty then
		informationIndex.APIKey = tostring(SettingsPage.APIKey.TextBox.Text)
		informationIndex.BoardID = tostring(SettingsPage.BoardID.TextBox.Text)
		informationIndex.Token = tostring(SettingsPage.Token.TextBox.Text)
	else
		Status.Text = "All Fields Must Be Used"
		wait(1)
		Status.Text = ""
	end
end)

SettingsPage.APIKey.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
	SettingsPage.APIKey.TextBox.Text = string.rep("*", #SettingsPage.APIKey.TextBox.Text)
end)

SettingsPage.Token.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
	SettingsPage.Token.TextBox.Text = string.rep("*", #SettingsPage.Token.TextBox.Text)
end)


--//LISTS

ListStartPage.CreateList.MouseButton1Click:Connect(function()
	MainWindowLayout:JumpToIndex(2)
end)

ListStartPage.ArchiveList.MouseButton1Click:Connect(function()
	MainWindowLayout:JumpToIndex(3)
end)

CreateListPage.Create.MouseButton1Click:Connect(function()
	local Name_isEmpty = CreateListPage.ListName.TextBox.Text:gsub("%s+", "") == ""
	
	if not Name_isEmpty then
		commandQueue.addToQueue("createList", {CreateListPage.ListName.TextBox.Text})
	else
		Status.Text = "All Fields Must Be Used"
		wait(1)
		Status.Text = ""
	end
end)

ArchiveListPage.Archive.MouseButton1Click:Connect(function()
	local Name_isEmpty = ArchiveListPage.ListName.TextBox.Text:gsub("%s+", "") == ""
	
	if not Name_isEmpty then
		commandQueue.addToQueue("archiveList", {ArchiveListPage.ListName.TextBox.Text})
	else
		Status.Text = "All Fields Must Be Used"
		wait(1)
		Status.Text = ""
	end
end)


--//CARDS
CardsStartPage.CreateCard.MouseButton1Click:Connect(function()
	MainWindowLayout:JumpToIndex(6)
end)

CardsStartPage.ArchiveCard.MouseButton1Click:Connect(function()
	MainWindowLayout:JumpToIndex(5)
end)

CreateCardPage.Create.MouseButton1Click:Connect(function()
	local Description_isEmpty = CreateCardPage.CardDescription.TextBox.Text:gsub("%s+", "") == ""
	local Name_isEmpty = CreateCardPage.CardName.TextBox.Text:gsub("%s+", "") == ""
	
	if not Description_isEmpty and not Name_isEmpty then
		commandQueue.addToQueue("createCard", {
			CreateCardPage.CardDescription.TextBox.Text, 
			CreateCardPage.CardName.TextBox.Text,
			CreateCardPage.CardDueDate.TextBox.Text,
			CreateCardPage.CardList.TextBox.Text
		})
	else
		Status.Text = "All Required Fields Must Be Filled"
		wait(1)
		Status.Text = ""
	end
end)

ArchiveCardPage.Archive.MouseButton1Click:Connect(function()
	local Name_isEmpty = ArchiveCardPage.CardName.TextBox.Text:gsub("%s+","") == ""
	
	if not Name_isEmpty then
		commandQueue.addToQueue("archiveCard", {ArchiveCardPage.CardName.TextBox.Text})
	else
		Status.Text = "All Required Fields Must Be Filled"
		wait(1)
		Status.Text = ""
	end
end)

--//PUBLISH
relloMainGui.Ribbon.Publish.MouseButton1Click:Connect(function()
	if debounce == false then
		debounce = true
		local status = trelloService:publish()
		if status == true then
			Status.Text = "Sucessfully Published Changes"
			wait(1)
			Status.Text = ""
		else
			Status.Text = "Error: View the output for more info"
			warn(status)
			wait(2)
			Status.Text = ""
		end
		debounce = false
	end
end)
