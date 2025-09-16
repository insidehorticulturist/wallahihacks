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

    return self
end

function ArtilleryArc:_findArtilleryReference()
    local plr = self.player
    if not plr then
        return nil
    end
    local character = plr.Character
    if not character then
        return nil
    end

    for _, inst in pairs(character:GetDescendants()) do
        if inst.Name == "ArtilleryReference" and inst:IsA("ObjectValue") and inst.Value then
            return inst.Value
        end
    end

    return nil
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

    for _ = 1, self.resolution do
        local part = Instance.new("Part")
        part.Name = "\255"
        part.Anchored = true
        part.CanCollide = false
        part.Size = Vector3.new(0.1, 0.1, 1)
        part.Material = Enum.Material.Neon
        part.Color = Color3.fromRGB(255, 255, 0)

        part.Parent = arcModel
        table.insert(self.arcParts, part)
    end

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
    if not Toggles or not Toggles.artyVisual or Toggles.artyVisual.Value == nil then
        return
    end

    if not Toggles.artyVisual.Value then
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

    local gravity = Vector3.new(0, -Workspace.Gravity, 0)
    local originCFrame = self.barrel.CFrame
    local startPosition = originCFrame.Position
    local direction = originCFrame.LookVector
    if direction.Magnitude == 0 then
        return
    end
    local velocity = direction.Unit * self.projectileSpeed

    local points = {}
    for i = 0, self.resolution do
        local t = (i / self.resolution) * self.totalDuration
        points[i + 1] = startPosition + velocity * t + 0.5 * gravity * t * t
    end

    if self.highlight and Options and Options.artyVisualColor then
        self.highlight.FillColor = Options.artyVisualColor.Value
    end

    local sizeVal = (Options and Options.artyVisualSize and Options.artyVisualSize.Value) or 0.1
    for i = 1, self.resolution do
        local a, b = points[i], points[i + 1]
        if a and b then
            local dir = b - a
            local distance = dir.Magnitude
            if distance > 0.0001 then
                local midPoint = (a + b) * 0.5
                local part = self.arcParts[i]
                if part then
                    part.Size = Vector3.new(sizeVal, sizeVal, distance)
                    part.Color = Options.artyVisualColor.Value
                    local ok, cf = pcall(function()
                        return CFrame.lookAt(midPoint, b)
                    end)
                    if ok and cf then
                        part.CFrame = cf
                    end
                end
            end
        end
    end
end

function ArtilleryArc:destroy()
    self:_destroyArc()
    self.player = nil
end

return ArtilleryArc
