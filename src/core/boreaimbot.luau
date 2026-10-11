--core/boreaimbot.luau
--by amedote

local Players = game:GetService('Players')
local Client = Players.LocalPlayer
local Mouse = Client:GetMouse()

local utility = require("../utility")

local main = {}
main.__index = main

local function findBoreAncestor(instance)
	while instance and instance.Parent do
		if instance.Name == 'Bore' then
			return instance
		end
		instance = instance.Parent
	end
	return nil
end

local function SetTarget(Bore, Target: Vector3)
	local setTarget = Bore:FindFirstChild("SetTarget")
	if setTarget then
		setTarget:FireServer(Bore, Target)
	end
end

function main.new()
	return setmetatable({}, main)
end

function main:start()
	-- set while we fire our own SetTarget so the hook lets it straight through
	local inside = false

	utility.hookNamecall("FireServer", function(old, self, ...)
		if inside or self.Name ~= "SetTarget" or not Toggles.BoreAimbot.Value then
			return old(self, ...)
		end

		local targetPart = Mouse.Target
		local hitPos = Mouse.Hit and Mouse.Hit.Position
		if not hitPos then
			return old(self, ...)
		end

		local bore = targetPart and findBoreAncestor(targetPart)
		local target = hitPos

		if bore then
			-- never aim at our own team's bores
			if bore:GetAttribute("Team") == Client.TeamColor then
				return
			end

			local tilt = bore:FindFirstChild("TiltAssembly")
			local barrel = tilt and tilt:FindFirstChild("Barrel")
			if barrel then
				target = barrel.Position
			end
		elseif targetPart and Toggles.AimAtCenterOfOtherParts.Value then
			target = targetPart.Position
		end

		inside = true
		local ok, err = pcall(SetTarget, self.Parent, target)
		inside = false

		if not ok then
			warn(err)
		end

		return
	end)
end

return main
