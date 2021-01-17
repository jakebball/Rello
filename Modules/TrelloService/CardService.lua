local CardService = {}

local HttpService = game:GetService("HttpService")

local informationIndex = require(script.Parent.Parent.InformationIndex)
local commandQueue = require(script.Parent.Parent.CommandQueue)

function CardService.createCard(BoardInfo, i, v)
	if informationIndex.APIKey and informationIndex.Token and BoardInfo and v[2] and v[3] and v[5] then
		
		local parentListId = false

		for _,list in ipairs(BoardInfo.lists) do
			if string.lower(list.name) == string.lower(v[5]) then
				parentListId = list.id
				break
			end
		end
		
		if parentListId then
			local success, response = pcall(function()
				local URL 
				
				if v[4] then
					URL = "https://api.trello.com/1/cards?key="..informationIndex.APIKey.."&token="..informationIndex.Token.."&name="..v[3].."&desc="..v[2].."&due="..v[4].."-24:00".."&dueComplete=false&idList="..parentListId
				else
					URL = "https://api.trello.com/1/cards?key="..informationIndex.APIKey.."&token="..informationIndex.Token.."&name="..v[3].."&desc="..v[2].."&dueComplete=false&idList="..parentListId
				end
				
				local responseDictionary = HttpService:RequestAsync({Url = URL, Method = "POST"})
				
				if not responseDictionary.Success then
					error(responseDictionary.StatusCode.." - "..responseDictionary.StatusMessage)
				end
			end)
			
			if not success then
				return response
			end
		end
	end
	table.remove(commandQueue.queue, i)
	return true
end

function CardService.archiveCard(BoardInfo, i, v)
	if informationIndex.APIKey and informationIndex.Token and BoardInfo and v[2] then
		local cardId = false

		for _,card in ipairs(BoardInfo.cards) do
			if string.lower(card.name) == string.lower(v[2]) and card.closed == false then
				cardId = card.id
				break
			end
		end
		
		if cardId then
			local success, response = pcall(function()
				local URL = "https://api.trello.com/1/cards/"..cardId.."?key="..informationIndex.APIKey.."&token="..informationIndex.Token.."&closed=true"
				
				local responseDictionary = HttpService:RequestAsync({Url = URL, Method = "PUT"})
				
				if not responseDictionary.Success then
					error(responseDictionary.StatusCode.." - "..responseDictionary.StatusMessage)
				end
			end)
			
			if not success then
				return response
			end		
		end
	end
	table.remove(commandQueue.queue, i)
	return true
end


return CardService 
