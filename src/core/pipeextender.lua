local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StructureUtil =
    require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utilities"):WaitForChild("StructureUtil"))

local main = {}
main.__index = main

function main.new()
    return setmetatable({}, main)
end

function main:start()
    local oldGetRootModel = StructureUtil.getRootModel

    function StructureUtil.getRootModel(...)
        local result = oldGetRootModel(...)

        if result and result:IsA("Model") and Toggles["PORTAFAB/ExtendPipeHitbox"].Value then
            local size = Options["PORTAFAB/ExtendPipeHitboxSize"].Value

            for _, descendant in ipairs(result:GetDescendants()) do
                if descendant:IsA("BasePart") and descendant.Name:lower():find("flange") then
                    descendant.Size = Vector3.new(size, 0.5, size)
                end
            end
        end

        return result
    end
end

return main
