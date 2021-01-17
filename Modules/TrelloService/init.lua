local TrelloService = {}

local HttpService = game:GetService("HttpService")

local commandQueue = require(script.Parent.CommandQueue)
local informationIndex = require(script.Parent.InformationIndex)

local ListService = require(script.ListService)
local CardService = require(script.CardService)

local isPublishing = false

--//FUNCTIONS
--[[
	publish()
		- returns string status
]]

local function deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = deepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

function TrelloService.publish()
	if isPublishing == false then
		isPublishing = true
		for i,v in ipairs(deepCopy(commandQueue.queue)) do
			local BoardInfo = false
			
			local IDSuccess, IDResponse = pcall(function()
				local URL = "https://api.trello.com/1/boards/"..informationIndex.BoardID.."?key="..informationIndex.APIKey.."&token="..informationIndex.Token.."&lists=all&cards=all"
				
				local BoardJSON = HttpService:RequestAsync({Url = URL, Method = "GET"})
				return HttpService:JSONDecode(BoardJSON.Body)
			end)
			
			if IDSuccess then
				BoardInfo = IDResponse
			end
			
			if v[1] == "createList" then
				local response = ListService.createList(BoardInfo, i, v)
				if not (response == true) then
					isPublishing = false
					return response
				end
			elseif v[1] == "archiveList" then
				local response = ListService.archiveList(BoardInfo, i, v)
				if not (response == true) then
					isPublishing = false
					return response
				end
			elseif v[1] == "createCard" then
				local response = CardService.createCard(BoardInfo, i, v)
				if not (response == true) then
					isPublishing = false
					return response
				end
			elseif v[1] == "archiveCard" then
				local response = CardService.archiveCard(BoardInfo, i, v)
				if not (response == true) then
					isPublishing = false
					return response
				end
			end
		end
	end
	isPublishing = false
	return true
end

return TrelloService
