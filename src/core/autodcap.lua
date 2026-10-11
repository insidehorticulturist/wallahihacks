-- by amedote
-- optimized for performance and low GC

local main = {}
main.__index = main

function main.new()
	return setmetatable({}, main)
end

--// Cached services and globals
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceStructure = RS:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("PlaceStructure")
local utility = require("../utility")

local newCFrame = CFrame.new
local angles = CFrame.Angles
local rad = math.rad

--// Valid structure types
local validNames = {
	["Arc Turret"] = true, ["Turret"] = true, ["Fabricator"] = true,
	["Automechanic"] = true, ["Boost Pad"] = true, ["Observer"] = true,
	["Spatial Anchor"] = true, ["Spawn Point"] = true, ["Shield Generator"] = true,
	["Point Defense"] = true
}

--// Compute offset + orientation for placement
local function computePlacementInfo(capModel, flange)
	local capPrimary = capModel.PrimaryPart or capModel:FindFirstChildWhichIsA("BasePart")
	if not capPrimary then return end

	local heightOffset = (capPrimary.Size.Y * 0.5) - 0.55
	local baseCFrame = flange.CFrame * newCFrame(0.6, heightOffset, 0)
	local snappedCFrame = utility.roundRotationTo15Degrees(baseCFrame)

	local flangeRot = flange.CFrame - flange.CFrame.Position
	local rotatedCFrame = flangeRot
		* angles(0, rad(90), 0)
		* angles(rad(-90), 0, 0)

	rotatedCFrame = newCFrame(snappedCFrame.Position) * rotatedCFrame

	return {
		CFrame = flange.CFrame:ToObjectSpace(rotatedCFrame),
		BasePart = flange
	}
end

--// Handles cloning and server placement of the distributor cap
local function placeDistributorCap(turret)
	local pipeFemale = turret:WaitForChild("PipeFemale", 5)
	if not pipeFemale then return end

	local flange = pipeFemale:WaitForChild("FemaleFlange", 5)
	if not flange then return end

	-- only read for its size, so use the template instead of cloning it
	local capModel = RS.Server.Structures.Iridium.Special.Tech:WaitForChild("Distributor Cap", 5)
	if not capModel then return end

	local placementInfo = computePlacementInfo(capModel, flange)
	if not placementInfo then return end

	PlaceStructure:FireServer("Distributor Cap", placementInfo, "FemaleFlange", flange)
end

--// Entry point
function main:start(structure)
	if not (Toggles and Toggles.AutoDCap and Toggles.AutoDCap.Value) then return end

	local name = structure.Name
	if not validNames[name] then return end
	if structure:GetAttribute("Builder") ~= LocalPlayer.Name then return end

	local dropdown = Options.AutoDCapDropdown.Value
	if dropdown and dropdown[name] then
		task.wait(Options.AutoDCapDelay.Value)
		placeDistributorCap(structure)
	end
end

return main
