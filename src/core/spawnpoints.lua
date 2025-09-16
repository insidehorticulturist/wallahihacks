local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local container = require("@Util/container")

local SpawnPointController =
    require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("Loader"):WaitForChild("SpawnPointController"))
local SpawnRequest = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("SpawnRequest")
local UpdateSpawnPads = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("UpdateSpawnPads")

local main = {}
main.__index = main

function main.new()
    return setmetatable({
        currentSpawn = nil,
    }, main)
end

function main:start()
    local this = self
    local oldSelect = SpawnPointController._select

    function SpawnPointController._select(...)
        local hasIndex = select(2, ...)

        if hasIndex then
            this.currentSpawn = select(2, ...)
        end

        return oldSelect(...)
    end
    container.instantTPCall:Connect(function()
        if this.currentSpawn == nil then
            local randomSpawn = SpawnPointController.padList[math.random(1, #SpawnPointController.padList)]

            if randomSpawn then
                SpawnRequest:InvokeServer(randomSpawn.Index, false)
            end
            return
        end

        SpawnRequest:InvokeServer(this.currentSpawn, false)
    end)

    container.instantRespawnCall:Connect(function()
        if this.currentSpawn == nil then
            local randomSpawn = SpawnPointController.padList[math.random(1, #SpawnPointController.padList)]

            if randomSpawn then
                SpawnRequest:InvokeServer(randomSpawn.Index, true)
            end
            return
        end

        SpawnRequest:InvokeServer(this.currentSpawn, true)
    end)

    Options.SelectedPadList:OnChanged(function(value)
        this.currentSpawn = value
    end)

    local function setUIList(pads)
        local withIndex = {}

        for _, v in pads do
            local tot = v.TeleportAvailabilityLevel or v.AvailabilityLevel

            if tot >= 1 then
                table.insert(withIndex, v.Index)
            end
        end

        Options.SelectedPadList:SetValues(withIndex)
    end

    UpdateSpawnPads.OnClientEvent:Connect(function(pads)
        setUIList(pads)
    end)

    if Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait() then
        setUIList(SpawnPointController.padList)
    end
end

function main:update()
    container.selectedSpawn = self.currentSpawn
end

return main
