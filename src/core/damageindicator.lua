local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local container = require("@Util/container")

local damageindicator = {}
damageindicator.__index = damageindicator

function damageindicator.new()
    return setmetatable({}, damageindicator)
end

local function applyDamageVisual(character)
    local humanoid = character:WaitForChild("Humanoid")
    local lastHealth = humanoid.Health

    humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        local currentHealth = humanoid.Health

        if currentHealth < lastHealth and container.lockedOn == nil then
            local foundHighlight = character:FindFirstChild("xaaaaaa")
            if foundHighlight then
                foundHighlight:Destroy()
            end

            local highlight = Instance.new("Highlight")
            highlight.FillColor = Options.DamageIndicatorColor.Value
            highlight.Parent = character
            highlight.Name = "xaaaaaa"
            highlight.FillTransparency = 0.05

            TweenService:Create(highlight, TweenInfo.new(1), {
                FillTransparency = 1,
                OutlineTransparency = 1,
            }):Play()

            task.delay(1, function()
                highlight:Destroy()
            end)
        end

        lastHealth = currentHealth
    end)
end

function damageindicator:start()
    for _, player in Players:GetPlayers() do
        applyDamageVisual(player.Character)
        player.CharacterAdded:Connect(applyDamageVisual)
    end

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(applyDamageVisual)
    end)
end

return damageindicator
