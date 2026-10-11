-- by amedote
-- usage: e to power, click to aim

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local StructureUtil =
    require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utilities"):WaitForChild("StructureUtil"))

local ContextButtonRemote =
    ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("ContextButton")

local main = {}
main.__index = main

local function getCurrentBore()
    local mouseLocation = UserInputService:GetMouseLocation()
    local camera = workspace.CurrentCamera
    local ray = camera:ScreenPointToRay(mouseLocation.X, mouseLocation.Y)

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances =
        { camera, CollectionService:GetTagged("ContextHintRaycastIgnore"), Players.LocalPlayer.Character }

    local result = workspace:Raycast(ray.Origin, ray.Direction * 9999, params)
    if result then
        return StructureUtil:getRootModel(result.Instance)
    end

    return nil
end

local function activateButton(button)
    if button then
        button:Fire()
        ContextButtonRemote:FireServer(button)
    end
end

function main.new()
    return setmetatable({}, main)
end

function main:start()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or not Toggles.AutoInteractBore.Value then
            return
        end

        local bore = getCurrentBore()

        if not bore then
            return
        end

        local TargetButton = bore:FindFirstChild("TargetButton")
        local PowerButton = bore:FindFirstChild("PowerButton")

        if input.UserInputType == Enum.UserInputType.MouseButton1 and TargetButton then
            ContextActionService:UnbindAction("SelectTarget")
            activateButton(TargetButton.ContextButton)
            ContextActionService:UnbindAction("SelectTarget")
        elseif input.KeyCode == Enum.KeyCode.E and PowerButton then
            activateButton(PowerButton.ContextButton)
        end
    end)
end
return main
