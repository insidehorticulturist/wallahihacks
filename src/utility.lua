local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CurrentCamera = workspace.CurrentCamera

local function get(types)
    local ok = if getmodules
        then getmodules
        else function()
            local format = {}

            for _, v in game:GetDescendants() do
                if IsA(v, "ModuleScript") then
                    table.insert(format, v)
                end
            end

            return format
        end

    for _, module in ok() do
        if module.Name == types then
            return require(module)
        end
    end

    return
end

local function GetClosestPlayer(fovRadius, teamCheck)
    local mousePos = UserInputService:GetMouseLocation()
    local fovSq = (fovRadius or 300) ^ 2

    local closestPlayer = nil
    local closestDistSq = fovSq

    for _, player in ipairs(Players:GetPlayers()) do
        if teamCheck then
            if player.Team == Players.LocalPlayer.Team then
                return
            end
        end

        if player == Players.LocalPlayer then
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

        local screenPos, onScreen = CurrentCamera:WorldToScreenPoint(rootPart.Position)
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
    local circlez = Drawing.new("Circle")
    circlez.Position = info.Position or Vector2.new(150, 150)
    circlez.Radius = info.Radius or 20
    circlez.Filled = false
    circlez.Thickness = info.Thickness or 2

    return circlez
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

local function square(info)
    local q = Drawing.new("Square")
    q.Visible = info.Visible or false
    q.Transparency = info.Transparency or 1
    q.Color = info.Color or Color3.fromRGB(0, 0, 0)

    q.Thickness = info.Thickness or 1
    q.Filled = info.Filled or false
    return q
end

local function line(info)
    local l = Drawing.new("Line")
    l.Visible = info.Visible or false
    l.Transparency = info.Transparency or 1
    l.Color = info.Color or Color3.fromRGB(0, 0, 0)

    l.Thickness = info.Thickness or 1
    return l
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

return {
    get = get,
    GetClosestPlayer = GetClosestPlayer,
    circle = circle,
    label = label,
    square = square,
    line = line,
    isAliveModel = isAliveModel,
    ActivateButton = ActivateButton
}
