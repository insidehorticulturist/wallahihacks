-- FloorPartModule.lua
local main = {}
main.__index = main

function main.new(options)
	local self = setmetatable({}, main)
	self.player = game.Players.LocalPlayer
	self.part = nil
	self.hrp = nil
	return self
end

function main:start()
	-- Reattach every time the player respawns
	game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
		self:setup(character)
	end)

	-- If the character already exists, start immediately
	if game.Players.LocalPlayer.Character then
		self:setup(game.Players.LocalPlayer.Character)
	end
end

function main:setup(character)
	local hrp = character:WaitForChild("HumanoidRootPart")

	-- Create the circular (cylindrical) part
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Cylinder
	part.Parent = workspace
	part.Color = Color3.fromRGB(255, 0, 0)
	part.CanCollide = false
	part.Anchored = true
	part.Transparency = 1 -- start invisible

	self.part = part
	self.hrp = hrp

	task.spawn(function()
		while character and character.Parent do
			self:update()
			task.wait()
		end
	end)
end

function main:update()
	if not Toggles.HeightLimitESP then 
		self.part.Transparency = 1
		return end
	if not self.part or not self.hrp then return end
	-- Update size from options
	if Options.HeightlimitSize.Value then
		self.part.Size = Vector3.new(0.1,Options.HeightlimitSize.Value,Options.HeightlimitSize.Value)
	end

	-- Update position while keeping it rotated flat
	local pos = self.hrp.Position
	self.part.CFrame = CFrame.new(pos.X, 252, pos.Z) * CFrame.Angles(0, 0, math.rad(90))

	-- Update fade distance from options
	local fadeDistance = 15
	local fadeSpeed =  0.1

	local distance = (self.hrp.Position - self.part.Position).Magnitude
	local targetTransparency = distance < fadeDistance and math.clamp(distance / fadeDistance, 0, 1) or 1
	self.part.Color = Options.HeighLimitColor.Value
	-- Smooth transparency transition
	self.part.Transparency = self.part.Transparency + (targetTransparency - self.part.Transparency) * fadeSpeed
end

return main
