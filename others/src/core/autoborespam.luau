-- core/borespamgpt.luau
-- by amedote

local main = {}
main.__index = main

local function SetTarget(Bore, Target: Vector3)
	local setTarget = Bore:WaitForChild("SetTarget")
	if setTarget then
		setTarget:FireServer(Bore, Target)
	end
end

-- structures to track aimed bores

local function createBoreStruct(bore)
    return {
        model = bore,
        boreThatItsAimingAt = nil,
        used = false,
    }
end

local function createEnemyBoreStruct(bore)
    return {
        model = bore,
        beingAimedAt = false,
    }
end

local function removeBoreStruct(list, bore)
    for i, struct in ipairs(list) do
        if struct.model == bore then
            table.remove(list, i)
            return struct
        end
    end
end

function main.new()
    return setmetatable({bores = {}, enemybores = {}}, main)
end

function main:start()
    local StructuresFolder = workspace.Structures
    local LocalPlayer = game:GetService("Players").LocalPlayer
	local TeamColor = LocalPlayer.TeamColor

	for _, child in ipairs(StructuresFolder:GetChildren()) do
		if child.Name == "Bore" then
			local Team = child:GetAttribute("Team")
			if Team == TeamColor then
				table.insert(self.bores, createBoreStruct(child))
			else
				table.insert(self.enemybores, createEnemyBoreStruct(child))
			end
		end
	end

    StructuresFolder.ChildAdded:Connect(function(Child)
        if Child.Name ~= "Bore" then
            return
        end

        local Builder = Child:GetAttribute("Builder")
        local Team = Child:GetAttribute("Team")
        local playerTeam = game:GetService("Players").LocalPlayer.TeamColor

        if Team ~= playerTeam then
            local Bore = createEnemyBoreStruct(Child)
            table.insert(self.enemybores, Bore)
            if Toggles.AutoBorespam.Value then
            -- retarget idle bore to new enemy bore
            for _, myBore in ipairs(self.bores) do
                if not myBore.used and myBore.model and myBore.model.Parent then
                    Bore.beingAimedAt = true
                    myBore.boreThatItsAimingAt = Bore.model
                    myBore.used = true

                    local tilt = Bore.model:WaitForChild("TiltAssembly")
                    local barrel = tilt and tilt:WaitForChild("Barrel")
                    if barrel then
                        SetTarget(myBore.model, barrel.Position)
                    end
                    break -- we only want one bore to target it so break the loop (delete this if u want idle bores to reaim at one bore) 
                end
            end
            end

            return
        end

        local Bore = createBoreStruct(Child)
        table.insert(self.bores, Bore)
        local chosen
        if Toggles.AutoBorespam.Value then
        if Toggles.AutoBorespamRandom.Value then
            local Available = {}
            for _, enemy in ipairs(self.enemybores) do
                if enemy.model and enemy.model.Parent and not enemy.beingAimedAt then
                    table.insert(Available, enemy)
                end
            end

            if #Available > 0 then
                chosen = Available[math.random(1, #Available)]
                chosen.beingAimedAt = true
            else
                if #self.enemybores > 0 then
                    chosen = self.enemybores[math.random(1, #self.enemybores)]
                end
            end
        else
            for _, enemy in ipairs(self.enemybores) do
                if enemy.model and enemy.model.Parent and not enemy.beingAimedAt then
                    chosen = enemy
                    enemy.beingAimedAt = true
                    break
                end
            end

            -- fallback if all enemy bores are being aimed at
            if not chosen and #self.enemybores > 0 then
                for _, enemy in ipairs(self.enemybores) do
                if enemy.model and enemy.model.Parent then
                    chosen = enemy
                break
            end
        end
    end
    end
end
        if Toggles.AutoBorespam.Value then
        if chosen and chosen.model and chosen.model:WaitForChild("TiltAssembly") then
            local barrel = chosen.model.TiltAssembly:WaitForChild("Barrel")
            if barrel then
                SetTarget(Bore.model, barrel.Position)
                
	            game:GetService('ReplicatedStorage')
		            :WaitForChild('Shared')
		            :WaitForChild('Remotes')
		            :WaitForChild('ContextButton')
		            :FireServer(Bore.model.PowerButton.ContextButton)
                    task.wait(0.7)

                Bore.boreThatItsAimingAt = chosen.model
                Bore.used = true
            end
        end
    end
    end)

    StructuresFolder.ChildRemoved:Connect(function(Child)
        if Child.Name ~= "Bore" then return end

        for _, enemy in ipairs(self.enemybores) do
            if enemy.model == Child then
                for _, myBore in ipairs(self.bores) do
                    if myBore.boreThatItsAimingAt == enemy.model then
                        myBore.boreThatItsAimingAt = nil
                        myBore.used = false

                        local Available = {}
                        for _, e in ipairs(self.enemybores) do
                            if e.model and e.model.Parent and not e.beingAimedAt and e.model ~= Child then
                                table.insert(Available, e)
                            end
                        end
                        if Toggles.AutoBorespam.Value then
                        if #Available > 0 then
                            local chosen = Available[math.random(1, #Available)]
                            chosen.beingAimedAt = true
                            myBore.boreThatItsAimingAt = chosen.model
                            myBore.used = true

                            if chosen.model:WaitForChild("TiltAssembly") then
                                local barrel = chosen.model.TiltAssembly:WaitForChild("Barrel")
                                if barrel then
                                    SetTarget(myBore.model, barrel.Position)
                                end
                            end
                        else
                        end
                    end
                    end
                end
                removeBoreStruct(self.enemybores, Child)
                return
            end
        end

        local removedBore = removeBoreStruct(self.bores, Child)
        if removedBore and removedBore.boreThatItsAimingAt then
            for _, enemy in ipairs(self.enemybores) do
                if enemy.model == removedBore.boreThatItsAimingAt then
                    enemy.beingAimedAt = false
                    break
                end
            end
        end
    end)
end

