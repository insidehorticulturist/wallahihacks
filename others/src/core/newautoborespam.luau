local main = {}
main.__index = main

local StructuresFolder = workspace.Structures
local LocalPlayer = game:GetService("Players").LocalPlayer
local TeamColor = LocalPlayer.TeamColor

local function SetTarget(Bore, Target: Vector3)
	local setTarget = Bore:WaitForChild("SetTarget")
	if setTarget then
		setTarget:FireServer(Bore, Target)
	end
end

local function createFriendlyBoreStruct(bore)
	return {
		model = bore,
		boreThatItsAimingAt = nil,
		used = false,
	}
end

local function createEnemyBoreStruct(bore)
	return {
		model = bore,
		beingAimedAtBy = {},
	}
end

function main.new()
	return setmetatable({bores = {}, enemybores = {}}, main)
end

-- 🔹 Track a bore and assign auto-aim
function main:trackBore(Child)
	if Child.Name ~= "Bore" then return end

	local Builder = Child:GetAttribute("Builder")
	local Team = Child:GetAttribute("TeamColor")
	local Bore

	if Builder == LocalPlayer.Name then
		-- Friendly bore
		Bore = createFriendlyBoreStruct(Child)
		table.insert(self.bores, Bore)

		-- Target first available enemy bore
		for _, enemy in ipairs(self.enemybores) do
			if enemy.model and enemy.model.Parent and #enemy.beingAimedAtBy == 0 then
				Bore.boreThatItsAimingAt = enemy.model
				Bore.used = true
				table.insert(enemy.beingAimedAtBy, Bore)
				local barrel = enemy.model:FindFirstChild("TiltAssembly") and enemy.model.TiltAssembly:FindFirstChild("Barrel")
				if barrel then
					SetTarget(Bore.model, barrel.Position)
					print("Friendly bore", Bore.model.Name, "is now aiming at enemy bore", enemy.model.Name)
				end
				break -- only target one
			end
		end

	elseif Team ~= LocalPlayer.TeamColor then
		-- Enemy bore
		Bore = createEnemyBoreStruct(Child)
		table.insert(self.enemybores, Bore)

		-- Retarget one idle friendly bore
		for _, myBore in ipairs(self.bores) do
			if not myBore.used and myBore.model and myBore.model.Parent then
				myBore.boreThatItsAimingAt = Bore.model
				myBore.used = true
				table.insert(Bore.beingAimedAtBy, myBore)

				local barrel = Bore.model:FindFirstChild("TiltAssembly") and Bore.model.TiltAssembly:FindFirstChild("Barrel")
				if barrel then
					SetTarget(myBore.model, barrel.Position)
					print("Idle bore", myBore.model.Name, "is now targeting new enemy bore", Bore.model.Name)
				end
				break -- only one bore
			end
		end
	end
end

function main:start()
	-- 🔹 Track all existing bores at script start
	for _, v in pairs(StructuresFolder:GetChildren()) do
		self:trackBore(v)
	end

	-- 🔹 Connect ChildAdded
	StructuresFolder.ChildAdded:Connect(function(Child)
		self:trackBore(Child)
	end)

	-- 🔹 Connect ChildRemoved
	StructuresFolder.ChildRemoved:Connect(function(Child)
		-- Remove friendly bore
		for i, bore in ipairs(self.bores) do
			if bore.model == Child then
				-- Free its target
				if bore.boreThatItsAimingAt then
					for _, enemy in ipairs(self.enemybores) do
						if enemy.model == bore.boreThatItsAimingAt then
							for j = #enemy.beingAimedAtBy, 1, -1 do
								if enemy.beingAimedAtBy[j] == bore then
									table.remove(enemy.beingAimedAtBy, j)
									break
								end
							end
						end
					end
				end
				table.remove(self.bores, i)
				break
			end
		end

		-- Remove enemy bore
		for i, enemy in ipairs(self.enemybores) do
			if enemy.model == Child then
				-- Free one friendly bore aiming at it
				for _, bore in ipairs(enemy.beingAimedAtBy) do
					bore.used = false
					bore.boreThatItsAimingAt = nil
				end
				table.remove(self.enemybores, i)
				break
			end
		end
	end)
end

return main
