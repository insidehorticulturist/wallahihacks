local sc = (debug and debug.setconstant) or setconstant
local gc = (debug and debug.getconstants) or getconstants
if not sc or not getgc or not gc then
		return 
end
local pop = game.Players.LocalPlayer.PlayerScripts.PlayerModule.CameraModule.ZoomController.Popper
function Toggle()
    for _, v in pairs(getgc()) do
	    if type(v) == 'function' and getfenv(v).script == pop then
		    for i, v1 in pairs(gc(v)) do
			    if tonumber(v1) == .25 then
			    	sc(v, i, 0)
			    elseif tonumber(v1) == 0 then
			    	sc(v, i, .25)
			    end
            end
	    end
    end
end

return Toggle