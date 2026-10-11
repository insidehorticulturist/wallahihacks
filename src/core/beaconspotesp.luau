-- by amedote
local main = {}
main.__index = main

function main.new()
    local self = setmetatable({}, main)
    self.beaconspots = {}
    return self
end

function main:start()
    local beaconspots = self.beaconspots
    
    for _, v in workspace.Map:GetChildren() do
        if v.Name == "ControlBlock1" then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Options.BeaconSpotColor.Value
            highlight.Enabled = Toggles.BeaconSpotESP.Value
            highlight.Parent = v
            table.insert(beaconspots, {v, highlight})
        end
    end

    Toggles.BeaconSpotESP:OnChanged(function(value)
        for _, spot in beaconspots do
            spot[2].Enabled = value
        end
    end)

    Options.BeaconSpotColor:OnChanged(function()
        for _, spot in beaconspots do
            spot[2].FillColor = Options.BeaconSpotColor.Value
        end
    end)
end

function main:unload()
    for _, spot in self.beaconspots do
        spot[2]:Destroy()
    end
    table.clear(self.beaconspots)
end

return main
