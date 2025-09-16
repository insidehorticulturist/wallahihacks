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
            for _, pipe in result:GetChildren() do
                local pipeFemale = pipe:FindFirstChild("PipeFemale")

                if pipeFemale then
                    for _, pip in pipeFemale:GetChildren() do
                        if pip.Name:find("Flange") then
                            pip.Size = Vector3.new(
                                Options["PORTAFAB/ExtendPipeHitboxSize"].Value,
                                0.5,
                                Options["PORTAFAB/ExtendPipeHitboxSize"].Value
                            )
                        end
                    end
                end

                if pipe:IsA("BasePart") and pipe.Name:find("Flange") then
                    pipe.Size = Vector3.new(
                        Options["PORTAFAB/ExtendPipeHitboxSize"].Value,
                        0.5,
                        Options["PORTAFAB/ExtendPipeHitboxSize"].Value
                    )
                end
            end
        end

        return result
    end
end

return main
