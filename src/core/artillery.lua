-- by nqjf and amedote
-- todo: maybe arty arcs for other players so you can see where they're aiming
-- todo: re-add back the size and coloring options. for some reason they were messing up the old ui lib

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local utility = require("../utility")

local ArtilleryArc = {}
ArtilleryArc.__index = ArtilleryArc

local DEFAULTS = {
	projectileSpeed = 137.23,
	totalDuration = 5,
	resolution = 30,
}

-- a still barrel skips redrawing, but the landing spot can still change under it
local LANDING_RECHECK = 0.2

local SPLASH_RADIUS = 3
local SPLASH_RING_WIDTH = 0.5
local SPLASH_CORE_RADIUS = 1

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

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.RespectCanCollide = true
	self.raycastParams = raycastParams

	-- splash marker where the shell lands, built from adornments so raycasts never hit it
	self.splashRing = nil
	self.splashCore = nil

	-- last inputs the arc was drawn with, so a still barrel costs nothing
	self.lastCFrame = nil
	self.lastGravity = nil
	self.lastSize = nil
	self.lastDraw = 0
	self.shownSegments = 0

	-- last style applied, so color and transparency are only written on change
	self.lastColor = nil
	self.lastTransparency = nil

	return self
end

local function isArtilleryReference(inst)
	return inst.Name == "ArtilleryReference" and inst:IsA("ObjectValue")
end

local function createSplashAdornment(radius, innerRadius)
	local adornment = Instance.new("CylinderHandleAdornment")
	adornment.Name = "\255"
	adornment.Adornee = workspace.Terrain -- terrain sits at the origin, so CFrames are world space
	adornment.Radius = radius
	adornment.InnerRadius = innerRadius
	adornment.Height = 0.05
	adornment.AlwaysOnTop = true -- the landing spot is often behind terrain, keep it visible
	adornment.ZIndex = 1
	adornment.Visible = false
	utility.parentToCoreGui(adornment)
	return adornment
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

	self.splashRing = createSplashAdornment(SPLASH_RADIUS, SPLASH_RADIUS - SPLASH_RING_WIDTH)
	self.splashCore = createSplashAdornment(SPLASH_CORE_RADIUS, 0)

	-- the arc and the shell ignore the artillery itself and our character
	self.raycastParams.FilterDescendantsInstances = { foundRef, self.player.Character }

	self.shownSegments = self.resolution
	self.lastCFrame = nil
	self.lastColor = nil
	self.lastTransparency = nil
	self.active = true
end

function ArtilleryArc:_destroyArc()
	if self.arcModel then
		self.arcModel:Destroy()
	end
	if self.splashRing then
		self.splashRing:Destroy()
	end
	if self.splashCore then
		self.splashCore:Destroy()
	end
	self.arcModel = nil
	self.highlight = nil
	self.splashRing = nil
	self.splashCore = nil
	self.arcParts = {}
	self.barrel = nil
	self.active = false
end

function ArtilleryArc:_applyStyle()
	local color = Options.artyVisualColor.Value
	local transparency = Options.artyVisualTransparency.Value or 0

	if color == self.lastColor and transparency == self.lastTransparency then
		return
	end
	self.lastColor = color
	self.lastTransparency = transparency

	self.highlight.FillColor = color
	self.highlight.FillTransparency = transparency

	for _, part in self.arcParts do
		part.Color = color
		part.Transparency = transparency
	end

	self.splashRing.Color3 = color
	self.splashRing.Transparency = transparency
	-- the filled center stays softer than the ring so the impact point underneath is still readable
	self.splashCore.Color3 = color
	self.splashCore.Transparency = 0.5 + transparency * 0.5
end

-- segments past the impact point are unparented so they (and the highlight) stop drawing
function ArtilleryArc:_showSegments(count)
	if count == self.shownSegments then
		return
	end
	self.shownSegments = count

	for i, part in self.arcParts do
		local parent = if i <= count then self.arcModel else nil
		if part.Parent ~= parent then
			part.Parent = parent
		end
	end
end

function ArtilleryArc:_setSplash(position, normal)
	local ring, core = self.splashRing, self.splashCore

	if not position then
		if ring.Visible then
			ring.Visible = false
			core.Visible = false
		end
		return
	end

	-- cylinder adornments run along Z, so point Z along the surface normal to lay it on the surface
	local up = if math.abs(normal.Y) > 0.99 then Vector3.xAxis else Vector3.yAxis
	local origin = position + normal * 0.05
	local cframe = CFrame.lookAt(origin, origin + normal, up)

	ring.CFrame = cframe
	core.CFrame = cframe

	if not ring.Visible then
		ring.Visible = true
		core.Visible = true
	end
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

	self:_applyStyle()

	local originCFrame = self.barrel.CFrame
	local gravityValue = Workspace.Gravity
	local sizeVal = Options.artyVisualSize.Value or 0.1
	local now = os.clock()

	-- nothing moved since the last draw, the arc is already right
	if
		originCFrame == self.lastCFrame
		and gravityValue == self.lastGravity
		and sizeVal == self.lastSize
		and now - self.lastDraw < LANDING_RECHECK
	then
		return
	end
	self.lastCFrame = originCFrame
	self.lastGravity = gravityValue
	self.lastSize = sizeVal
	self.lastDraw = now

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

	local raycastParams = self.raycastParams
	local shown = 0
	local landingPosition, landingNormal

	for i = 1, self.resolution do
		local a, b = points[i], points[i + 1]

		-- cut the arc where the shell would hit something
		local hit = Workspace:Raycast(a, b - a, raycastParams)
		if hit then
			b = hit.Position
			landingPosition = hit.Position
			landingNormal = hit.Normal
		end

		local part = self.arcParts[i]
		local distance = (b - a).Magnitude
		if part and distance > 0.0001 then
			shown = i
			part.Size = Vector3.new(sizeVal, sizeVal, distance)
			table.insert(movedParts, part)
			table.insert(cframes, CFrame.lookAt((a + b) * 0.5, b))
		end

		if hit then
			break
		end
	end

	-- parent before moving, BulkMoveTo only works on parts in the world
	self:_showSegments(shown)
	self:_setSplash(landingPosition, landingNormal)

	-- one engine call for every segment instead of a CFrame write per part
	Workspace:BulkMoveTo(movedParts, cframes, Enum.BulkMoveMode.FireCFrameChanged)
end

function ArtilleryArc:destroy()
	self:_destroyArc()
	self:_trackCharacter(nil)
	self.player = nil
end

return ArtilleryArc
