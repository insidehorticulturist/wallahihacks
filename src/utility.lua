local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local function GetClosestPlayer(fovRadius, teamCheck)
    local mousePos = UserInputService:GetMouseLocation()
    local fovSq = (fovRadius or 300) ^ 2
    local camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer

    local closestPlayer = nil
    local closestDistSq = fovSq

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then
            continue
        end

        if teamCheck and player.Team == LocalPlayer.Team then
            continue
        end

        local character = player.Character
        if not character then
            continue
        end

        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
        if not (humanoid and humanoid.Health > 0) then
            continue
        end

        local rootPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            continue
        end

        local screenPos, onScreen = camera:WorldToScreenPoint(rootPart.Position)
        if not onScreen then
            continue
        end

        local dx, dy = screenPos.X - mousePos.X, screenPos.Y - mousePos.Y
        local distSq = dx * dx + dy * dy

        if distSq < closestDistSq then
            closestDistSq = distSq
            closestPlayer = player
        end
    end

    if closestPlayer then
        return closestPlayer.Character, math.sqrt(closestDistSq)
    end
    return nil, nil
end

local function circle(info)
    local drawing = Drawing.new("Circle")
    drawing.Position = info.Position or Vector2.new(150, 150)
    drawing.Radius = info.Radius or 20
    drawing.Filled = false
    drawing.Thickness = info.Thickness or 2

    return drawing
end

local function label(info)
    local text = Drawing.new("Text")
    text.Text = info.Text or "Hello, World!"
    text.Position = info.Position or Vector2.new(150, 150)
    text.Color = info.Color or Color3.new(0.968627, 0.972549, 0.968627)
    text.Size = 18
    text.Font = Drawing.Fonts.Monospace
    text.Visible = true

    return text
end

local function line(info)
    local drawing = Drawing.new("Line")
    drawing.Visible = info.Visible or false
    drawing.Transparency = info.Transparency or 1
    drawing.Color = info.Color or Color3.fromRGB(0, 0, 0)

    drawing.Thickness = info.Thickness or 1
    return drawing
end

local function isAliveModel(character)
    if character and character.IsDescendantOf(character, workspace) and character.PrimaryPart ~= nil then
        return character
    end

    return false
end

local function ActivateButton(button)
	game:GetService('ReplicatedStorage')
		:WaitForChild('Shared')
		:WaitForChild('Remotes')
		:WaitForChild('ContextButton')
		:FireServer(button)
end

-- removes the first occurrence of value from an array
local function removeValue(list, value)
    for i, v in ipairs(list) do
        if v == value then
            table.remove(list, i)
            return
        end
    end
end

-- snaps each rotation axis of cf to the nearest 15 degrees
local function roundRotationTo15Degrees(cf)
    local x, y, z = cf:ToEulerAnglesXYZ()
    local function roundTo15(angle)
        return math.rad(math.round(math.deg(angle) / 15) * 15)
    end
    return CFrame.new(cf.Position) * CFrame.Angles(roundTo15(x), roundTo15(y), roundTo15(z))
end

-- one shared __namecall hook. every namecall in the game goes through it, so stacking a hook
-- per feature costs fps; handlers are looked up by method name and get (old, self, ...)
local namecallHandlers = {}
local oldNamecall

local function hookNamecall(method, handler)
    assert(namecallHandlers[method] == nil, `namecall handler for {method} already registered`)
    namecallHandlers[method] = handler

    if oldNamecall then
        return
    end

    oldNamecall = hookmetamethod(
        game,
        "__namecall",
        LPH_JIT_MAX(function(self, ...)
            local handler = namecallHandlers[getnamecallmethod()]

            if handler and not checkcaller() then
                return handler(oldNamecall, self, ...)
            end

            return oldNamecall(self, ...)
        end)
    )
end

return {
    GetClosestPlayer = GetClosestPlayer,
    circle = circle,
    label = label,
    line = line,
    isAliveModel = isAliveModel,
    ActivateButton = ActivateButton,
    removeValue = removeValue,
    roundRotationTo15Degrees = roundRotationTo15Degrees,
    hookNamecall = hookNamecall,
}
