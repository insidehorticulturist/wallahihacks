-- by nqjf and amedote
-- todo: maybe arty arcs for other players so you can see where they're aiming
-- todo: maybe stop arty arc from building after it touches a part
-- todo: re-add back the size and coloring options. for some reason they were messing up the old ui lib

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local ArtilleryArc = {}
ArtilleryArc.__index = ArtilleryArc

local DEFAULTS = {
	projectileSpeed = 137.23,
	totalDuration = 5,
	resolution = 30,
}

function ArtilleryArc.new()
	local self = setmetatable({}, ArtilleryArc)

	self.player = Players.LocalPlayer
	self.barrel = nil
	self.arcModel = nil
	self.arcParts = {}
	self.highlight = nil
	self.active = false

	self.projectileSpeed = DEFAULTS.projectileSpeed
	self.totalDuration = DEFAULTS.totalDuration
	self.resolution = DEFAULTS.resolution

	-- the ArtilleryReference value is tracked with events instead of scanning the character every frame
	self.trackedCharacter = nil
	self.referenceValue = nil
	self.characterConnections = {}

	-- reused every frame so the arc doesn't allocate new tables
	self.points = {}
	self.movedParts = {}
	self.cframes = {}

	-- last inputs the arc was drawn with, so a still barrel costs nothing
	self.lastCFrame = nil
	self.lastGravity = nil
	self.lastSize = nil

	return self
end

local function isArtilleryReference(inst)
	return inst.Name == "ArtilleryReference" and inst:IsA("ObjectValue")
end

function ArtilleryArc:_trackCharacter(character)
	for _, connection in self.characterConnections do
		connection:Disconnect()
	end
	table.clear(self.characterConnections)

	self.trackedCharacter = character
	self.referenceValue = nil

	if not character then
		return
	end

	-- prefer a reference that's already set, but keep an empty one since its Value can be filled in later
	for _, inst in character:GetDescendants() do
		if isArtilleryReference(inst) then
			self.referenceValue = inst
			if inst.Value then
				break
			end
		end
	end

	table.insert(self.characterConnections, character.DescendantAdded:Connect(function(inst)
		if isArtilleryReference(inst) then
			self.referenceValue = inst
		end
	end))

	table.insert(self.characterConnections, character.DescendantRemoving:Connect(function(inst)
		if inst == self.referenceValue then
			self.referenceValue = nil
		end
	end))
end

function ArtilleryArc:_findArtilleryReference()
	local plr = self.player
	if not plr then
		return nil
	end

	local character = plr.Character
	if character ~= self.trackedCharacter then
		self:_trackCharacter(character)
	end

	local referenceValue = self.referenceValue
	return referenceValue and referenceValue.Value
end

function ArtilleryArc:_buildArc(foundRef)
	if not foundRef then
		return
	end
	local tilt = foundRef:FindFirstChild("TiltAssembly")
	local barrel = tilt and tilt:FindFirstChild("Barrel")

	if not barrel then
		return
	end

	if self.arcModel then
		self:_destroyArc()
	end

	self.barrel = barrel

	local arcModel = Instance.new("Model")
	arcModel.Name = "\255"
	arcModel.Parent = self.barrel

	local highlight = Instance.new("Highlight")

	highlight.Name = "ArcHighlight"
	highlight.Adornee = arcModel
	highlight.FillColor = Color3.fromRGB(255, 255, 0)
	highlight.FillTransparency = 0
	highlight.OutlineColor = Color3.new(1, 1, 1)
	highlight.OutlineTransparency = 1
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Parent = arcModel

	self.arcModel = arcModel
	self.highlight = highlight

	for i = 1, self.resolution do
		local part = Instance.new("Part")
		part.Name = "\255"
		part.Anchored = true
		part.CanCollide = false
		-- the arc is purely visual: keep it out of raycasts (mouse, placement), touches and shadows
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Size = Vector3.new(0.1, 0.1, 1)
		part.Material = Enum.Material.Neon
		part.Color = Options.artyVisualColor.Value or Color3.fromRGB(30, 160, 36)

		part.Parent = arcModel
		table.insert(self.arcParts, part)
	end

	self.lastCFrame = nil
	self.active = true
end

function ArtilleryArc:_destroyArc()
	if self.arcModel then
		self.arcModel:Destroy()
	end
	self.arcModel = nil
	self.highlight = nil
	self.arcParts = {}
	self.barrel = nil
	self.active = false
end

function ArtilleryArc:update()
	if not Toggles or not Toggles.artyVisual.Value then
		if self.active then
			self:_destroyArc()
		end
		return
	end

	local foundRef = self:_findArtilleryReference()

	if not foundRef then
		if self.active then
			self:_destroyArc()
		end
		return
	end

	if self.active and self.barrel and self.barrel:IsDescendantOf(foundRef) == false then
		self:_destroyArc()
	end
	if not self.active then
		self:_buildArc(foundRef)
	end

	if not self.active or not self.barrel then
		return
	end

	if self.highlight and Options and Options.artyVisualColor then
		local color = Options.artyVisualColor.Value
		if self.highlight.FillColor ~= color then
			self.highlight.FillColor = color
		end
	end

	local originCFrame = self.barrel.CFrame
	local gravityValue = Workspace.Gravity
	local sizeVal = Options.artyVisualSize.Value or 0.1

	-- nothing moved since the last frame, the arc is already right
	if originCFrame == self.lastCFrame and gravityValue == self.lastGravity and sizeVal == self.lastSize then
		return
	end
	self.lastCFrame = originCFrame
	self.lastGravity = gravityValue
	self.lastSize = sizeVal

	local gravity = Vector3.new(0, -gravityValue, 0)
	local startPosition = originCFrame.Position
	local direction = originCFrame.LookVector
	if direction.Magnitude == 0 then
		return
	end
	local velocity = direction.Unit * self.projectileSpeed

	local points = self.points
	for i = 0, self.resolution do
		local t = (i / self.resolution) * self.totalDuration
		points[i + 1] = startPosition + velocity * t + 0.5 * gravity * t * t
	end

	local movedParts = self.movedParts
	local cframes = self.cframes
	table.clear(movedParts)
	table.clear(cframes)

	for i = 1, self.resolution do
		local a, b = points[i], points[i + 1]
		local part = self.arcParts[i]
		if part then
			local distance = (b - a).Magnitude
			if distance > 0.0001 then
				part.Size = Vector3.new(sizeVal, sizeVal, distance)
				table.insert(movedParts, part)
				table.insert(cframes, CFrame.lookAt((a + b) * 0.5, b))
			end
		end
	end

	-- one engine call for every segment instead of a CFrame write per part
	Workspace:BulkMoveTo(movedParts, cframes, Enum.BulkMoveMode.FireCFrameChanged)
end

function ArtilleryArc:destroy()
	self:_destroyArc()
	self:_trackCharacter(nil)
	self.player = nil
end

return ArtilleryArc
