-- by nqjf

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
        local index = select(2, ...)

        if index then
            this.currentSpawn = index
        end

        return oldSelect(...)
    end

    -- spawns at the selected pad, or a random one if none is selected
    local function requestSpawn(isRespawn)
        if this.currentSpawn == nil then
            local padList = SpawnPointController.padList
            if #padList == 0 then
                return
            end

            local randomSpawn = padList[math.random(1, #padList)]

            if randomSpawn then
                SpawnRequest:InvokeServer(randomSpawn.Index, isRespawn)
            end
            return
        end

        SpawnRequest:InvokeServer(this.currentSpawn, isRespawn)
    end

    container.instantTPCall:Connect(function()
        requestSpawn(false)
    end)

    container.instantRespawnCall:Connect(function()
        requestSpawn(true)
    end)

    Options.SelectedPadList:OnChanged(function(value)
        this.currentSpawn = value
    end)

    local function setUIList(pads)
        local withIndex = {}

        for _, v in pads do
            local tot = v.TeleportAvailabilityLevel or v.AvailabilityLevel or 0

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
