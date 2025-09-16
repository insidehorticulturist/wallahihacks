local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

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

function main:start()
    local o
    o = hookmetamethod(
        game,
        "__namecall",
        LPH_JIT_MAX(function(self, ...)
            if checkcaller() then
                return o(self, ...)
            end

            local nmc = getnamecallmethod()

            if nmc == "Raycast" then
                local character = Players.LocalPlayer.Character
                if
                    Toggles["PORTAFAB/InfiniteRange"].Value
                    and debug.getinfo(3).name == "getMouseInfo"
                    and debug.traceback():find("ContextButtons")
                    and character
                then
                    local result = o(self, ...)

                    if result then
                        return {
                            Instance = result.Instance,
                            Position = character.HumanoidRootPart.Position,
                        }
                    end
                end
            elseif nmc == "GetAttribute" then
                local name = select(1, ...)

                if Toggles.JetPackMods.Value then
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
            elseif Toggles.FallDamage.Value and nmc == "TakeDamage" then
                return
            end

            return o(self, ...)
        end)
    )

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
