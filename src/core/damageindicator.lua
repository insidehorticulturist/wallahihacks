-- by nqjf
-- rewritten for 77ware by amedote

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local container = require("@Util/container")

local damageindicator = {}
damageindicator.__index = damageindicator

function damageindicator.new()
    return setmetatable({}, damageindicator)
end

local function applyDamageVisual(character)
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        humanoid = character:WaitForChild("Humanoid", 5) 
        if not humanoid then return end
    end

    local lastHealth = humanoid.Health

    humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        local currentHealth = humanoid.Health
        -- skip the silent aim target, its esp already shows the locked-on color
        if currentHealth < lastHealth and Toggles.DamageIndicator.Value and container.lockedOn ~= character then
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
                if highlight and highlight.Parent then
                    highlight:Destroy()
                end
            end)
        end
        lastHealth = currentHealth
    end)
end

local function watchPlayer(player)
    player.CharacterAdded:Connect(applyDamageVisual)
end

function damageindicator:start()
    for _, player in Players:GetPlayers() do
        if player.Character then
            applyDamageVisual(player.Character)
        end
        watchPlayer(player)
    end

    Players.PlayerAdded:Connect(watchPlayer)
end

return damageindicator
