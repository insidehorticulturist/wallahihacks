local ReplicatedStorage = game:GetService('ReplicatedStorage')

local PlaceStructures = ReplicatedStorage:WaitForChild('Shared')
    :WaitForChild('Remotes')
    :WaitForChild('PlaceStructure')

local CFrameOffset = CFrame.new(
    0,
    1.669189453125,
    0.25,
    -1,
    -8.742277657347586e-08,
    -0,
    -8.742277657347586e-08,
    1,
    -8.742277657347586e-08,
    7.64274186065882e-15,
    -8.742277657347586e-08,
    -1
)

local o
o = hookmetamethod(game, '__namecall', function(self, ...)
    local method = getnamecallmethod()

    if checkcaller() or method ~= "FireServer" or self ~= PlaceStructures then
        return o(self, ...)
    end

    local args = { ... }
    local Type = args[1]
    local Args = args[2]

    if Type == "Submersible" then

        local PlacedOn = Args.BasePart and Args.BasePart:FindFirstAncestor("Submersible")

        if PlacedOn then

            local newArgs = table.clone(Args)
            newArgs.CFrame = CFrameOffset

            return o(self, Type, newArgs)
        else
        end
    end

    return o(self, ...)
end)
