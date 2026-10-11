-- by amedote
-- optimized version

local utility = require("../utility")

local main = {}
main.__index = main

function main.new()
	return setmetatable({
		Beams = {}
	}, main)
end

-- cached globals
local Effects = workspace.Effects
local ColorSeqKey = ColorSequenceKeypoint.new
local ColorSeq = ColorSequence.new
local insert = table.insert

local DEFAULT_COLOR = Color3.fromRGB(0, 255, 255)

-- precompute color sequence
local function createColorSequence(color1, color2)
	return ColorSeq({ ColorSeqKey(0, color1), ColorSeqKey(1, color2) })
end

local function applyColor(beam)
	local c1, c2
	if Toggles.ChangeBeamColors.Value then
		c1 = Options.FirstBeamColor.Value
		c2 = Options.SecondBeamColor.Value
	else
		c1, c2 = DEFAULT_COLOR, DEFAULT_COLOR
	end

	beam.Color = createColorSequence(c1, c2)
end

local function updateAll(beams)
	for i = 1, #beams do
		applyColor(beams[i])
	end
end

local function isIridiumBeam(v)
	return v:IsA("Beam") and v.Name == "IridiumBeam"
end

function main:start()
	local beams = self.Beams

	-- initialize existing beams
	for _, v in Effects:GetChildren() do
		if isIridiumBeam(v) then
			insert(beams, v)
			applyColor(v)
		end
	end

	-- listen for new beams
	Effects.ChildAdded:Connect(function(v)
		if not isIridiumBeam(v) then return end
		insert(beams, v)
		task.wait(0.1) -- required for proper Beam setup
		if v and v.Parent == Effects then
			applyColor(v)
		end
	end)

	-- listen for beam removals
	Effects.ChildRemoved:Connect(function(v)
		if isIridiumBeam(v) then
			utility.removeValue(beams, v)
		end
	end)

	-- update all beams on option change
	local function handleColorChange()
		updateAll(beams)
	end

	Toggles.ChangeBeamColors:OnChanged(handleColorChange)
	Options.FirstBeamColor:OnChanged(handleColorChange)
	Options.SecondBeamColor:OnChanged(handleColorChange)
end

return main
