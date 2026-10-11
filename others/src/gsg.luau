local v1 = game:GetService("ReplicatedStorage")
local u2 = game:GetService("RunService")
local u3 = v1.Server.Structures
local u4 = v1.Shared.Remotes.PlaceStructure
local u5 = v1.Shared.Remotes.IsTutorial:InvokeServer()
local u6 = require(script:WaitForChild("Dragger"))
local u7 = require(script.Dragger.Snapping)
local u8 = {}
local u9 = false
local u10 = nil
local u11 = nil
function u8.enterPlacementMode(_, p12) --[[Anonymous function at line 17]]
    --[[
    Upvalues:
        [1] = u10
        [2] = u7
        [3] = u6
        [4] = u8
        [5] = u11
        [6] = u9
        [7] = u2
    --]]
    u10 = p12
    u7.rotation = 0
    u7.snapPoint = 0
    u7.cachedSnapPoints = nil
    u6.pipePoints = {}
    u6.WorldSnapPart = nil
    u6.StructureSnapPartName = nil
    local v13 = u8:getStructureModel(p12)
    if not v13 then
        error("No structure model found of type " .. tostring(p12))
    end
    if p12 == "Pipe" then
        v13 = v13.InitialPlaceModel:Clone()
        v13.Name = "Pipe"
    end
    u6:setModel(v13:Clone())
    if u11 then
        u11:Disconnect()
    end
    u9 = true
    u11 = u2.Heartbeat:Connect(u6.update)
endj
function u8.getStructureModel(_, p14) --[[Anonymous function at line 44]]
    --[[
    Upvalues:
        [1] = u8
    --]]
    if u8.structureHash == nil then
        u8.structureHash = u8:generateStructureHash()
    end
    return u8.structureHash[p14]
end
function u8.generateStructureHash(_) --[[Anonymous function at line 52]]
    --[[
    Upvalues:
        [1] = u3
    --]]
    local u15 = {}
    local function u19(p16, p17) --[[Anonymous function at line 55]]
        --[[
        Upvalues:
            [1] = u19
        --]]
        for _, v18 in ipairs(p16:GetChildren()) do
            if v18:IsA("Model") then
                p17(v18)
            elseif v18:IsA("Folder") then
                u19(v18, p17)
            elseif v18:IsA("Configuration") then
                u19(v18, p17)
            end
        end
    end
    u19(u3, function(p20) --[[Anonymous function at line 73]]
        --[[
        Upvalues:
            [1] = u15
        --]]
        u15[p20.Name] = p20
    end)
    return u15
end
function u8.rotate(_, p21) --[[Anonymous function at line 80]]
    --[[
    Upvalues:
        [1] = u7
    --]]
    u7.rotation = (u7.rotation + (p21 or 90)) % 360
end
function u8.changeSnapPoint(_) --[[Anonymous function at line 84]]
    --[[
    Upvalues:
        [1] = u7
    --]]
    u7.snapPoint = u7.snapPoint + 1
end
function u8.abortPlacement(_) --[[Anonymous function at line 88]]
    --[[
    Upvalues:
        [1] = u6
        [2] = u11
        [3] = u9
    --]]
    if u6.rangeIndicator then
        u6.rangeIndicator:Destroy()
        u6.rangeIndicator = nil
    end
    if u6.model then
        u6.model:Destroy()
        u6.model = nil
    end
    if u11 then
        u11:Disconnect()
        u11 = nil
    end
    u9 = false
end
function u8.confirmPlacement(_) --[[Anonymous function at line 107]]
    --[[
    Upvalues:
        [1] = u9
        [2] = u6
        [3] = u10
        [4] = u8
        [5] = u5
        [6] = u4
    --]]
    if u9 then
        if u6.canPlace then
            if u10 ~= "Pipe" then
                u8:abortPlacement()
                u4:FireServer(u10, u6.placementInfo, u6.StructureSnapPartName, u6.WorldSnapPart)
                return true
            end
            if #u6.pipePoints == 0 then
                u6.model:Destroy()
                u6.model = Instance.new("Model")
                u6.model.Name = "Pipe"
                u8:rotate(180)
                if u5 then
                    game.ReplicatedStorage.Shared.Remotes.EventReported:FireServer({
                        ["Name"] = "PortafabBlueprintPlaced"
                    })
                end
            end
            local v22 = u6.pipePoints
            local v23 = u6.placementInfo
            table.insert(v22, v23)
            if #u6.pipePoints == 2 then
                u8:abortPlacement()
                u4:FireServer("Pipe", u6.pipePoints)
                u9 = false
                return true
            end
        end
        return false
    end
end
return u8
