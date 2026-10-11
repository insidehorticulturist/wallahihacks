-- by nqjf

local Players = game:GetService("Players")

local container = require("@Util/container")
local utility = require("../utility")
local lerpColor = require("../lerpcolor")

-- health bar colors precomputed per health percent, so the color lerp never runs per frame
local HEALTH_COLORS = {}
do
    local healthBarLerp = lerpColor(Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0))
    for percent = 0, 100 do
        HEALTH_COLORS[percent] = healthBarLerp(percent / 100)
    end
end

-- ui settings, read once per frame in main:update and shared by every entity
local frame = {}

local main = {}
main.__index = main

function main.new()
    return setmetatable({
        entities = {},
    }, main)
end

local function DecimalToPercentage(decimalValue)
    decimalValue = math.clamp(decimalValue, 0, 1)
    local percent = decimalValue * 100
    return math.floor(percent)
end

local function getIridiumLevel(character)
    local tank = character:FindFirstChild("IridiumTank")
    local indicator = tank and tank:FindFirstChild("Indicator")
    local meter = indicator and indicator:FindFirstChild("IridiumMeter")
    local mesh = meter and meter:FindFirstChild("Mesh")

    if mesh and mesh:IsA("DataModelMesh") then
        return mesh.Scale.Y
    end

    return nil
end

function main:addEsp(player, character)
    character = character or player.Character

    local label = utility.label({})
    label.Center = true

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.4
    highlight.Enabled = false

    local healthBar = utility.line({ Color = Color3.fromRGB(0, 255, 0), Thickness = 1 })
    local Bar = utility.line({ Color = Color3.fromRGB(10, 10, 10), Thickness = 3, Transparency = 0.4 })

    local Box_Lines = {}
    for i = 1, 8 do
        Box_Lines[i] = utility.line({})
    end

    -- cached parts and last written values; drawing and instance writes are only made on change
    local root, hum
    local prevhealth
    local lastText, lastBoxColor, lastLabelColor, lastFillColor
    local labelVisible = true -- utility.label starts visible
    local barVisible = false
    local boxVisible = false

    local function setLabelVisible(state)
        if labelVisible ~= state then
            labelVisible = state
            label.Visible = state
        end
    end

    local function setBarVisible(state)
        if barVisible ~= state then
            barVisible = state
            healthBar.Visible = state
            Bar.Visible = state
        end
    end

    local function setBoxVisible(state)
        if boxVisible ~= state then
            boxVisible = state
            for i = 1, 8 do
                Box_Lines[i].Visible = state
            end
        end
    end

    local function setHighlightEnabled(state)
        if state and highlight.Parent ~= character then
            highlight.Parent = character
        end
        if highlight.Enabled ~= state then
            highlight.Enabled = state
        end
    end

    local function hide()
        setBoxVisible(false)
        setBarVisible(false)
        setLabelVisible(false)
    end

    -- locked-on color wins, then team color, then the given default
    local function pickColor(default)
        if container.lockedOn == character then
            return frame.lockedColor
        end

        return if frame.useTeamColor then player.TeamColor.Color else default
    end

    return {
        update = function()
            local localrootpart = frame.localRoot
            if not localrootpart then
                hide()
                return
            end

            if not (root and root.Parent == character) then
                root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
            end
            if not (hum and hum.Parent == character) then
                hum = character:FindFirstChildOfClass("Humanoid")
            end

            if not (root and hum) then
                hide()
                return
            end

            local rootPosition = root.Position
            local root_pos, onscreen = frame.camera:WorldToViewportPoint(rootPosition)

            if not onscreen then
                hide()
                return
            end

            local dist = (rootPosition - localrootpart.Position).Magnitude
            local espLists = frame.lists

            local ratio = 2500 / root_pos.Z

            local newsize_x = ratio / 2
            local newsize_y = ratio * 1.75 / 2

            local root_x = root_pos.X
            local root_y = root_pos.Y

            label.Position = Vector2.new(root_x, root_y - newsize_y - label.TextBounds.Y)

            local text = if espLists["Name"] then character.Name else ""

            if espLists["Health"] then
                local Hum_Health = hum.Health
                local Hum_MaxHealth = hum.MaxHealth
                local HealthRatio = if Hum_MaxHealth > 0 then Hum_Health / Hum_MaxHealth else 0

                text = `{math.round(HealthRatio * 100)}% {text}`

                local offsetX = math.clamp(math.round(200 / root_pos.Z), 4, 8)

                local Right = root_x + newsize_x
                local Top = root_y - newsize_y
                local Bottom = root_y + newsize_y

                local barPos = Right + offsetX

                Bar.From = Vector2.new(barPos, Top)
                Bar.To = Vector2.new(barPos, Bottom)

                local Length = math.abs((Bottom - 1) - (Top + 1))

                local HealthLength = Length * HealthRatio
                healthBar.From = Vector2.new(barPos, Bottom - 1 - HealthLength)
                healthBar.To = Vector2.new(barPos, Bottom - 1)

                if Hum_Health ~= prevhealth then
                    healthBar.Color = HEALTH_COLORS[math.clamp(math.round(HealthRatio * 100), 0, 100)]
                    prevhealth = Hum_Health
                end

                setBarVisible(true)
            else
                setBarVisible(false)
            end

            if espLists["Iridium"] then
                local iridium = getIridiumLevel(character)
                if iridium then
                    text = ` {text} Iridium: {DecimalToPercentage(iridium)}`
                end
            end

            if espLists["Distance"] then
                text = `{text} ({math.round(dist)})`
            end

            if text ~= lastText then
                lastText = text
                label.Text = text
            end

            if espLists["Box"] then
                local Dir1 = Vector2.new(ratio / 4, 0)
                local Dir2 = Vector2.new(0, ratio / 4)

                local TL = Vector2.new(root_x - newsize_x, root_y - newsize_y)
                local TR = Vector2.new(root_x + newsize_x, root_y - newsize_y)
                local BL = Vector2.new(root_x - newsize_x, root_y + newsize_y)
                local BR = Vector2.new(root_x + newsize_x, root_y + newsize_y)

                Box_Lines[1].From = TL
                Box_Lines[1].To = TL + Dir1

                Box_Lines[2].From = TL
                Box_Lines[2].To = TL + Dir2

                Box_Lines[3].From = TR
                Box_Lines[3].To = TR - Dir1

                Box_Lines[4].From = TR
                Box_Lines[4].To = TR + Dir2

                Box_Lines[5].From = BL
                Box_Lines[5].To = BL + Dir1

                Box_Lines[6].From = BL
                Box_Lines[6].To = BL - Dir2

                Box_Lines[7].From = BR
                Box_Lines[7].To = BR - Dir1

                Box_Lines[8].From = BR
                Box_Lines[8].To = BR - Dir2

                local boxColor = pickColor(frame.boxColor)
                if boxColor ~= lastBoxColor then
                    lastBoxColor = boxColor
                    for i = 1, 8 do
                        Box_Lines[i].Color = boxColor
                    end
                end

                setBoxVisible(true)
            else
                setBoxVisible(false)
            end

            if espLists["Highlight"] then
                local fillColor = pickColor(frame.boxColor)
                if fillColor ~= lastFillColor then
                    lastFillColor = fillColor
                    highlight.FillColor = fillColor
                end

                setHighlightEnabled(true)
            else
                setHighlightEnabled(false)
            end

            local labelColor = pickColor(frame.labelColor)
            if labelColor ~= lastLabelColor then
                lastLabelColor = labelColor
                label.Color = labelColor
            end

            setLabelVisible(true)
        end,

        destroy = function()
            hide()

            label:Remove()
            Bar:Remove()
            healthBar:Remove()

            for i = 1, #Box_Lines do
                Box_Lines[i]:Remove()
            end

            highlight:Destroy()
        end,
    }
end

function main:update()
    local entities = self.entities

    if not Toggles.playersVisual.Value then
        for character, entity in entities do
            entity.destroy()
            entities[character] = nil
        end
        return
    end

    local LocalPlayer = Players.LocalPlayer
    local localCharacter = LocalPlayer.Character

    frame.localRoot = if utility.isAliveModel(localCharacter)
        then localCharacter:FindFirstChild("HumanoidRootPart") or localCharacter.PrimaryPart
        else nil
    frame.camera = workspace.CurrentCamera
    frame.lists = Options["playersVisualLists"].Value
    frame.useTeamColor = Toggles["playersVisualUseTeamColor"].Value
    frame.lockedColor = Options["SilentAim/Color"].Value
    frame.boxColor = Options["BoxColor"].Value
    frame.labelColor = Options.LabelColor.Value

    local teamCheck = Toggles.playersVisualTeamcheck.Value

    for _, player in Players:GetPlayers() do
        if player == LocalPlayer then
            continue
        end

        local character = player.Character
        if not character then
            continue
        end

        local entity = entities[character]

        -- also drops teammates that got an esp before teamcheck was turned on
        if teamCheck and player.Team == LocalPlayer.Team then
            if entity then
                entity.destroy()
                entities[character] = nil
            end
            continue
        end

        if not entity then
            entities[character] = self:addEsp(player, character)
        end
    end

    for character, entity in entities do
        if character:IsDescendantOf(workspace) then
            entity.update()
        else
            entity.destroy()
            entities[character] = nil
        end
    end
end

return main
