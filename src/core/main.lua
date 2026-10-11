-- by amedote

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local utility = require("../utility")

local ToolProducer = require(
    ReplicatedStorage:WaitForChild("Client")
        :WaitForChild("Loader")
        :WaitForChild("StructureNetworkingController")
        :WaitForChild("Components")
        :WaitForChild("ToolProducer")
)

local main = {}
main.__index = main

function main.new()
    return setmetatable({}, main)
end

-- the handler runs one frame below the old standalone hook (the shared dispatcher calls it),
-- unless that call was a tail call, so look for getMouseInfo at both depths
local function calledFromMouseInfo()
    for level = 3, 4 do
        local info = debug.getinfo(level)
        if info and info.name == "getMouseInfo" then
            return true
        end
    end

    return false
end

function main:start()
    -- this is the bs i was talking about in readme that they added, i have no idea what it is lmao nqjf really wanted to commercialize this for some reason
    utility.hookNamecall("Raycast", function(old, self, ...)
        local character = Players.LocalPlayer.Character
        if
            Toggles["PORTAFAB/InfiniteRange"].Value
            and calledFromMouseInfo()
            and debug.traceback():find("ContextButtons")
            and character
        then
            local result = old(self, ...)

            if result then
                return {
                    Instance = result.Instance,
                    Position = character.HumanoidRootPart.Position,
                }
            end
        end

        return old(self, ...)
    end)

    utility.hookNamecall("GetAttribute", function(old, self, ...)
        if Toggles.JetPackMods.Value then
            local name = ...

            if name == "MaxThrustTime" then
                return Options.MaxThrustTime.Value
            end

            if name == "CooldownTime" then
                return Options.CooldownTime.Value
            end

            if name == "ThrustPower" then
                return Options.PowerThrust.Value
            end
        end

        return old(self, ...)
    end)

    Toggles.InstantProduceWeapons:OnChanged(function(bool)
        if bool then
            ToolProducer.SpringPanelConfig = { frequency = 0, dampeningRatio = 2 }
            ToolProducer.AnimationDuration = 0
            ToolProducer.LinearArmConfig = { velocity = 100 }
        else
            ToolProducer.SpringPanelConfig = { frequency = 3, dampeningRatio = 1 }
            ToolProducer.AnimationDuration = 0.25
            ToolProducer.LinearArmConfig = { velocity = 1 }
        end
    end)
end

return main
