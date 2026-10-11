local main = {}
main.__index = main

function main.new()
    return setmetatable({}, main)
end

local validNames = {
    ["Arc Turret"] = true,
    ["Turret"] = true,
    ["Fabricator"] = true,
    ["Automechanic"] = true,
    ["Boost Pad"] = true,
    ["Observer"] = true,
    ["Spatial Anchor"] = true,
    ["Spawn Point"] = true,
    ["Shield Generator"] = true,
    ["Point Defense"] = true
}

local function roundRotationTo15Degrees(cf: CFrame)
    local xRot, yRot, zRot = cf:ToEulerAnglesXYZ()
    local positionOnly = CFrame.new(cf.Position)
    local function roundTo15(angle)
        return math.rad(math.round(math.deg(angle) / 15) * 15) 
    end
    return positionOnly * CFrame.Angles(roundTo15(xRot), roundTo15(yRot), roundTo15(zRot))
end

local function computePlacementInfo(capModel, flange)
    local capPrimary = capModel:FindFirstChildWhichIsA('BasePart')
    if not capPrimary then
        return
    end 
    local heightOffset = capPrimary.Size.Y / 2 -0.55
    local baseCFrame = flange.CFrame * CFrame.new(0.6, heightOffset, 0)
    local snappedCFrame = roundRotationTo15Degrees(baseCFrame)
    local flangeRotation = flange.CFrame - flange.CFrame.Position
    local rotatedCFrame = flangeRotation * CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(math.rad(-90), 0, 0) 
    rotatedCFrame = CFrame.new(snappedCFrame.Position) * rotatedCFrame 
    return {
        CFrame = flange.CFrame:ToObjectSpace(rotatedCFrame),
        BasePart = flange, 
    } 
end 

local function placeDistributorCap(turret)
    local pipeFemale = turret:WaitForChild('PipeFemale', 5)
    if not pipeFemale then
        return
    end
    local flange = pipeFemale:WaitForChild('FemaleFlange', 5)
    if not flange then
        return
    end
    local capModel = game:GetService("ReplicatedStorage").Server.Structures.Iridium.Special.Tech:WaitForChild("Distributor Cap"):Clone()
    local placementInfo = computePlacementInfo(capModel, flange)
    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("PlaceStructure"):FireServer( "Distributor Cap", placementInfo, 'FemaleFlange', flange ) 
end

function DCap(structure)

    if not validNames[structure.Name] then
        return
    end
    if structure:GetAttribute("Builder") ~= game:GetService("Players").LocalPlayer.Name then
        return
    end
  
    placeDistributorCap(structure)
end

function main:start(structure)
    if not Toggles and Toggles.AutoDCap then return end
    DCap(structure)
end



function main:stop()

end



return main
