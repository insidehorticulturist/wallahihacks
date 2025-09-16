local Players = game:GetService("Players")
local CurrentCamera = workspace.CurrentCamera

local container = require("@Util/container")
local utility = require("../utility")

local LerpColorModule = loadstring(game:HttpGet("https://pastebin.com/raw/wRnsJeid"))()
local HealthBarLerp = LerpColorModule:Lerp(Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0))

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

function main:addEsp(player)
    local label = utility.label({})
    label.Center = true

    local highlight = Instance.new("Highlight")

    local healthBar = utility.line({ Color = Color3.fromRGB(0, 255, 0), Thickness = 1 })
    local Bar = utility.line({ Color = Color3.fromRGB(10, 10, 10), Thickness = 3, Transparency = 0.4 })

    local prevhealth = nil

    local Box_Lines = {}
    for i = 1, 8 do
        Box_Lines[i] = utility.line({})
    end

    local function Box_Vis(state, mode)
        if state == false then
            for i = 1, 8 do
                Box_Lines[i].Visible = false
            end
        elseif state and mode == 1 then
            for i = 1, 4 do
                Box_Lines[i].Visible = true
            end
            for i = 5, 8 do
                Box_Lines[i].Visible = false
            end
        elseif state and mode == 2 then
            for i = 1, 8 do
                Box_Lines[i].Visible = true
            end
        end
    end

    local function Lines_Color(col)
        for i = 1, #Box_Lines do
            Box_Lines[i].Color = col
        end
    end

    return {
        update = function()
            local character = player.Character
            if not utility.isAliveModel(Players.LocalPlayer.Character) then
                return
            end

            local localrootpart = Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                or Players.LocalPlayer.Character.PrimaryPart
            local root_part = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
            local hum = character:FindFirstChildOfClass("Humanoid")

            if localrootpart and root_part then
                local root_pos, onscreen = CurrentCamera:WorldToViewportPoint(root_part.Position)
                local dist = (root_part.Position - localrootpart.Position).magnitude

                if onscreen then
                    local ratio = 2500 / root_pos.Z

                    local newsize_x = ratio / 2
                    local newsize_y = ratio * 1.75 / 2

                    local root_x = root_pos.X
                    local root_y = root_pos.Y

                    label.Position = Vector2.new(root_x, root_y - newsize_y - label.TextBounds.Y)
                    label.Text = ""

                    if Options["playersVisualLists"].Value["Name"] then
                        label.Text = character.Name
                    end

                    if Options["playersVisualLists"].Value["Health"] then
                        label.Text = `{math.round(hum.Health / hum.MaxHealth * 100)}% {label.Text}`

                        local Hum_Health = hum.Health
                        local Hum_MaxHealth = hum.MaxHealth

                        local offsetX = math.clamp(math.round(200 / root_pos.Z), 4, 8)

                        local Right = root_x + newsize_x
                        local Top = root_y - newsize_y
                        local Bottom = root_y + newsize_y

                        local barPos = Right + offsetX

                        Bar.From = Vector2.new(barPos, Top)
                        Bar.To = Vector2.new(barPos, Bottom)

                        local HealthRatio = Hum_Health / Hum_MaxHealth
                        local Length = math.abs((Bottom - 1) - (Top + 1))

                        local HealthLength = Length * HealthRatio
                        healthBar.From = Vector2.new(barPos, Bottom - 1 - HealthLength)
                        healthBar.To = Vector2.new(barPos, Bottom - 1)

                        if Hum_Health ~= prevhealth then
                            healthBar.Color = HealthBarLerp(HealthRatio)
                            prevhealth = Hum_Health
                        end

                        healthBar.Visible = true
                        Bar.Visible = true
                    else
                        healthBar.Visible = false
                        Bar.Visible = false
                    end

                    if Options["playersVisualLists"].Value["Iridium"] then
                        pcall(function()
                            label.Text = ` {label.Text} Iridium: {DecimalToPercentage(
                                character.IridiumTank.Indicator.IridiumMeter.Mesh.Scale.Y
                            )}`
                        end)
                    end

                    if Options["playersVisualLists"].Value["Distance"] then
                        label.Text = `{label.Text} ({math.round(dist)})`
                    end

                    if Options["playersVisualLists"].Value["Box"] then
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

                        if container.lockedOn == player.Character then
                            Lines_Color(Options["SilentAim/Color"].Value)
                        else
                            Lines_Color(
                                if Toggles["playersVisualUseTeamColor"].Value
                                    then player.TeamColor.Color
                                    else Options["BoxColor"].Value
                            )
                        end

                        if Box_Lines[8].Visible == false or Box_Lines[1].Visible == false then
                            Box_Vis(true, 2)
                        end
                    else
                        Box_Vis(false)
                    end

                    if Options["playersVisualLists"].Value["Highlight"] then
                        highlight.Name = "penisHacks"
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

                        if container.lockedOn == player.Character then
                            highlight.FillColor = Options["SilentAim/Color"].Value
                        else
                            highlight.FillColor = if Toggles["playersVisualUseTeamColor"].Value
                                then player.TeamColor.Color
                                else Options["BoxColor"].Value
                        end

                        highlight.FillTransparency = 0.4
                        highlight.Parent = player.Character
                        highlight.Enabled = true
                    else
                        highlight.Enabled = false
                    end

                    label.Visible = true

                    if container.lockedOn == player.Character then
                        label.Color = Options["SilentAim/Color"].Value
                    else
                        label.Color = if Toggles["playersVisualUseTeamColor"].Value
                            then player.TeamColor.Color
                            else Options.LabelColor.Value
                    end
                else
                    Box_Vis(false)
                    label.Visible = false
                    Bar.Visible = false
                    healthBar.Visible = false
                end
            end
        end,

        destroy = function()
            Box_Vis(false)
            label.Visible = false
            Bar.Visible = false
            healthBar.Visible = false

            label:Remove()
            Bar:Remove()
            healthBar:Remove()

            for i = 1, #Box_Lines do
                Box_Lines[i]:Remove()
            end
        end,
    }
end

function main:update()
    if Toggles.playersVisual.Value then
        for _, player in Players:GetPlayers() do
            if player == Players.LocalPlayer then
                continue
            end

            if Toggles.playersVisualTeamcheck.Value then
                if player.Team == Players.LocalPlayer.Team then
                    continue
                end
            end

            local character = player.Character

            if character and self.entities[character] == nil then
                self.entities[character] = self:addEsp(player)
            end
        end
    else
        for key, object in self.entities do
            object.destroy()
            self.entities[key] = nil
        end
    end

    for key, object in self.entities do
        if key and not key.IsDescendantOf(key, workspace) then
            self.entities[key] = nil
            object.destroy()
        end
    end

    for _, object in self.entities do
        object.update()
    end
end

return main
