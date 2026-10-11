-- by amedote

local utility = require("../utility")

local DEFAULT_COLOR = Color3.fromRGB(0, 255, 255)

local STRUCTURES = workspace.Structures
local Client = game:GetService("Players").LocalPlayer

local main = {}
main.__index = main

local function applyColor(Bores)
    for _, Bore in ipairs(Bores) do
        local turretCenter = Bore:FindFirstChild("TurretCenter")
        if turretCenter then
            local previewBeam = turretCenter:FindFirstChild("PreviewBeam")
            if previewBeam then
                if Toggles.PreviewBeamColorChange.Value then
                    previewBeam.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Options.PreviewBeamColorOne.Value),
                        ColorSequenceKeypoint.new(1, Options.PreviewBeamColorTwo.Value)
                    })
                else
                    previewBeam.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, DEFAULT_COLOR),
                        ColorSequenceKeypoint.new(1, DEFAULT_COLOR)
                    })
                end
            end
        end

        local material = if Toggles.NeonBores.Value then Enum.Material.Neon else Enum.Material.Plastic
        local tiltAssembly = Bore:FindFirstChild("TiltAssembly")
        if tiltAssembly then
            local BeamParts = tiltAssembly:FindFirstChild("BeamParts")
            if BeamParts then
                for _, v in BeamParts:GetChildren() do
                    v.Material = material
                end
            end
        end
    end
end

function main.new()
    return setmetatable({
        Bores = {}
    }, main)
end

function main:start()
    local Bores = self.Bores

    for _, Child in ipairs(STRUCTURES:GetChildren()) do
        if Child.Name == "Bore" and Child:GetAttribute("Builder") == Client.Name then
            table.insert(Bores, Child)
        end
    end

    STRUCTURES.ChildAdded:Connect(function(Child)
        if Child.Name == "Bore" and Child:GetAttribute("Builder") == Client.Name then
            table.insert(Bores, Child)

            task.wait(0.1)
            applyColor({ Child })
        end
    end)

    STRUCTURES.ChildRemoved:Connect(function(Child)
        if Child.Name == "Bore" and Child:GetAttribute("Builder") == Client.Name then
            utility.removeValue(Bores, Child)
        end
    end)

    Toggles.PreviewBeamColorChange:OnChanged(function()
        applyColor(Bores)
    end)

    Toggles.NeonBores:OnChanged(function()
        applyColor(Bores)
    end)

    Options.PreviewBeamColorOne:OnChanged(function()
        if Toggles.PreviewBeamColorChange.Value then
            applyColor(Bores)
        end
    end)
    Options.PreviewBeamColorTwo:OnChanged(function()
        if Toggles.PreviewBeamColorChange.Value then
            applyColor(Bores)
        end
    end)
end

return main
