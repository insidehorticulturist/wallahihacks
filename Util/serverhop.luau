local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local PlaceId = game.PlaceId

local function serverhop()
	-- thanks to Amity for fixing
	local servers = {}
	local req = game:HttpGet(
		"https://games.roblox.com/v1/games/"
			.. PlaceId
			.. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true"
	)
	local body = HttpService:JSONDecode(req)

	if body and body.data then
		for i, v in next, body.data do
			if
				type(v) == "table"
				and tonumber(v.playing)
				and tonumber(v.maxPlayers)
				and v.playing < v.maxPlayers
				and v.id ~= JobId
			then
				table.insert(servers, 1, v.id)
			end
		end
	end

	if #servers > 0 then
		TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], Players.LocalPlayer)
	end
end

return {
	serverhop = serverhop,
	rejoin = function()
		TeleportService:Teleport(game.PlaceId)
	end,
}
