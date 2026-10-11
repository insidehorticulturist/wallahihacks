-- by amedote
-- todo: instead of using 252 as heightlimit grab it from the server config
-- todo: fade distance and other customizability options ( they are alr implemented just needs to be fixed in the gui file )

-- the disc is a handle adornment, not a part. adornments aren't BaseParts, so raycasts,
-- Mouse.Target and the game's placement system can't hit them, and nothing is added to workspace

local Players = game:GetService("Players")

local HEIGHT_LIMIT = 252
local FADE_DISTANCE = 15
local FADE_SPEED = 0.1
local DISC_ROTATION = CFrame.Angles(math.rad(90), 0, 0) -- cylinder adornments run along Z, so lay it flat

local main = {}
main.__index = main

function main.new()
	local self = setmetatable({}, main)
	self.player = Players.LocalPlayer
	self.adornment = nil
	self.hrp = nil
	self.transparency = 1
	self.size = nil
	self.color = nil
	return self
end

function main:start()
	local adornment = Instance.new("CylinderHandleAdornment")
	adornment.Name = "\255"
	adornment.Adornee = workspace.Terrain -- terrain sits at the origin, so CFrame below is world space
	adornment.Height = 0.1
	adornment.AlwaysOnTop = false
	adornment.Transparency = 1
	adornment.Visible = false

	-- keep it out of workspace when we're allowed to
	if not pcall(function()
		adornment.Parent = game:GetService("CoreGui")
	end) then
		adornment.Parent = workspace.Terrain
	end

	self.adornment = adornment
end

function main:_getRootPart()
	local character = self.player.Character
	if not character then
		return nil
	end

	local hrp = self.hrp
	if not (hrp and hrp.Parent == character) then
		hrp = character:FindFirstChild("HumanoidRootPart")
		self.hrp = hrp
	end

	return hrp
end

function main:_hide()
	self.transparency = 1
	if self.adornment.Visible then
		self.adornment.Visible = false
	end
end

function main:update()
	local adornment = self.adornment
	if not adornment then return end

	if not Toggles.HeightLimitESP.Value then
		self:_hide()
		return
	end

	local hrp = self:_getRootPart()
	if not hrp then
		self:_hide()
		return
	end

	local pos = hrp.Position
	local distance = math.abs(HEIGHT_LIMIT - pos.Y)
	local targetTransparency = if distance < FADE_DISTANCE then distance / FADE_DISTANCE else 1

	local transparency = self.transparency + (targetTransparency - self.transparency) * FADE_SPEED
	self.transparency = transparency

	-- fully faded out, skip the property writes until we get close again
	if targetTransparency == 1 and transparency > 0.99 then
		if adornment.Visible then
			adornment.Visible = false
		end
		return
	end

	local size = Options.HeightlimitSize.Value
	if size and size ~= self.size then
		self.size = size
		adornment.Radius = size / 2
	end

	local color = Options.HeighLimitColor.Value
	if color ~= self.color then
		self.color = color
		adornment.Color3 = color
	end

	adornment.CFrame = CFrame.new(pos.X, HEIGHT_LIMIT, pos.Z) * DISC_ROTATION
	adornment.Transparency = transparency
	adornment.Visible = true
end

return main
