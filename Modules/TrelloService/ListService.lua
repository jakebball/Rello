local ListService = {}

local HttpService = game:GetService("HttpService")

local informationIndex = require(script.Parent.Parent.InformationIndex)
local commandQueue = require(script.Parent.Parent.CommandQueue)

function ListService.createList(BoardInfo, i, v)
	if informationIndex.APIKey and BoardInfo and informationIndex.Token and v[2] then				
		local success, response = pcall(function()
			local URL = "https://api.trello.com/1/lists?key="..informationIndex.APIKey.."&token="..informationIndex.Token.."&name="..v[2].."&idBoard="..BoardInfo.id

			local responseDictionary = HttpService:RequestAsync({Url = URL, Method = "POST"})
			
			if not responseDictionary.Success then
				error(responseDictionary.StatusCode.." - "..responseDictionary.StatusMessage)
			end
		end)

		if not success then
			return response
		end
	end
	table.remove(commandQueue.queue, i)
	return true
end

function ListService.archiveList(BoardInfo, i, v)
	if informationIndex.APIKey and BoardInfo and informationIndex.Token then	
		
		local listId = false

		for _,list in ipairs(BoardInfo.lists) do
			if string.lower(list.name) == string.lower(v[2]) and list.closed == false then
				listId = list.id
				break
			end
		end
		
		if listId then
			local success, response = pcall(function()
				local URL = "https://api.trello.com/1/lists/"..listId.."?key="..informationIndex.APIKey.."&token="..informationIndex.Token.."&closed=true"

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

return ListService
