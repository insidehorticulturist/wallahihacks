--core/autoshield.luau

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Util = require("../utility")

local nextSize = 1

function StructurePlaced(structure)
    if not Toggles.AutoShield then return end
    if structure.Name ~= "Shield Generator" and structure.Name ~= "Spatial Anchor" then
        return
    end    
    if structure:GetAttribute("Team") ~= LocalPlayer.TeamColor then  return end
    if structure:GetAttribute("Builder") ~= LocalPlayer.Name then  return end



    if structure.Name == "Shield Generator" then
        local MediumButton = structure:WaitForChild("MediumButton"):WaitForChild("ContextButton")
        local SmallButton  = structure:WaitForChild("SmallButton"):WaitForChild("ContextButton")
        local EnableButton = structure:WaitForChild("EnableButton"):WaitForChild("ContextButton")
        local Panel = structure:WaitForChild("Panel"):WaitForChild("SurfaceGui"):WaitForChild("Text")
        if not (MediumButton and SmallButton and Panel) then return end

        if Panel.Text == "Off" then
            Util.ActivateButton(EnableButton)
            if nextSize == 1 then
            elseif nextSize == 2 then
                Util.ActivateButton(MediumButton)
            else
                Util.ActivateButton(SmallButton)
            end

            nextSize = nextSize % 3 + 1
        end
    else
        local EnableButton = structure:WaitForChild("EnableButton"):WaitForChild("ContextButton")
        Util.ActivateButton(EnableButton)
    end

end

return StructurePlaced