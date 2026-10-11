-- by amedote
-- nccam function taken from Infinite Yield FE by Edge
-- https://infyiff.github.io/Download.html

local sc = (debug and debug.setconstant) or setconstant
local gc = (debug and debug.getconstants) or getconstants
if not sc or not getgc or not gc then
	-- executor can't edit constants, hand back a no-op so the keybind doesn't error
	return function() end
end
local pop = game.Players.LocalPlayer.PlayerScripts.PlayerModule.CameraModule.ZoomController.Popper
-- scanning getgc is slow, so find the popper's functions once and reuse them
local popperFunctions
local function getPopperFunctions()
    if not popperFunctions then
        popperFunctions = {}
        for _, v in pairs(getgc()) do
            if type(v) == 'function' and getfenv(v).script == pop then
                table.insert(popperFunctions, v)
            end
        end
    end
    return popperFunctions
end

local function Toggle()
    for _, v in getPopperFunctions() do
        for i, v1 in pairs(gc(v)) do
            if tonumber(v1) == .25 then
                sc(v, i, 0)
            elseif tonumber(v1) == 0 then
                sc(v, i, .25)
            end
        end
    end
end

return Toggle