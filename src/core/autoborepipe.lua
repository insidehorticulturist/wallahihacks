local utility = require("../utility")

local main = {}
main.__index = main

local function computePlacementInfo(capModel, flange)
    local capPrimary = capModel:FindFirstChildWhichIsA('BasePart')
    if not capPrimary then
        return
    end
    local heightOffset = capPrimary.Size.Y / 2 - 2.2
    local baseCFrame = flange.CFrame * CFrame.new(-0.8, heightOffset, 0)
    local snappedCFrame = utility.roundRotationTo15Degrees(baseCFrame)
    local flangeRotation = flange.CFrame - flange.CFrame.Position
    local rotatedCFrame = flangeRotation
        * CFrame.Angles(0, math.rad(90), 0)
        * CFrame.Angles(math.rad(90), 0, 0)
    rotatedCFrame = CFrame.new(snappedCFrame.Position) * rotatedCFrame
    return {
        CFrame = flange.CFrame:ToObjectSpace(rotatedCFrame),
        BasePart = flange,
    }
end

local function PlaceFourWay(item)
    local pipeFemale = item:WaitForChild('PipeFemale', 5)
    if not pipeFemale then
        return
    end
    local flange = pipeFemale:WaitForChild('FemaleFlange', 5)
    if not flange then
        return
    end

    -- only read for its size, so use the template instead of cloning it
    local capModel = game.ReplicatedStorage.Server.Structures.Iridium.Pipes:WaitForChild('Four-Way', 5)
    if not capModel then
        return
    end

    local placementInfo = computePlacementInfo(capModel, flange)
    if not placementInfo then
        return
    end

    game.ReplicatedStorage.Shared.Remotes.PlaceStructure:FireServer(
        'Four-Way',
        placementInfo,
        'FemaleFlange4',
        flange
    )
end

function main.new()
    return setmetatable({}, main)
end

function main:start()
    workspace.Structures.ChildAdded:Connect(function(Child)
        if Toggles.AutoBorePipe.Value then
            if Child.Name == "Bore" and Child:GetAttribute("Builder") == game:GetService("Players").LocalPlayer.Name then
                PlaceFourWay(Child)
            end
        end
    end)
end

return main
