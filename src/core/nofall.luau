-- by unknown

local Players = game:GetService("Players")

local Client = Players.LocalPlayer

local function GetFunctionByNameFromScript(targetScript, functionName)
    local matchingFunctions = {}

    for _, garbageCollectedObject in ipairs(getgc()) do 
        if type(garbageCollectedObject) == "function" and debug.info(garbageCollectedObject, "n") == functionName and getfenv(garbageCollectedObject).script == targetScript then 
            table.insert(matchingFunctions, garbageCollectedObject)
        end 
    end 

    return matchingFunctions
end 

local function MatchCallbackToConnection(Connections, Callback)
    for _, Connection in ipairs(Connections) do 
        if Connection.Function == Callback then 
            return Connection
        end 
    end
end 

local function GetFallDamageScript()
    local IsCharacter = Client.Character 

    if not IsCharacter then 
        return 
    end 

    return IsCharacter:FindFirstChild("FallDamageScript")
end 

local function GetFallDamageHandler()
    local IsFallDamageScript = GetFallDamageScript()

    if not IsFallDamageScript then 
        return 
    end 

    return  GetFunctionByNameFromScript(IsFallDamageScript, "OnStateChanged")
end 

local function GetLocalHumanoid()
    local IsCharacter = Client.Character

    return IsCharacter and IsCharacter:FindFirstChildOfClass("Humanoid")
end 

local Player = {}

-- returns true if the fall damage connection was found and updated
function Player.SetFallDamage(IsFallDamage)
    local FallDamageHandler = GetFallDamageHandler()
    local LocalHumanoid = GetLocalHumanoid()

    if not (FallDamageHandler and LocalHumanoid) then
        return false
    end

    local Connections = getconnections(LocalHumanoid.StateChanged)
    local Found = false

    for _, MatchingCallback in ipairs(FallDamageHandler) do 
        local RespectiveConnection = MatchCallbackToConnection(Connections, MatchingCallback)

        if RespectiveConnection then
            Found = true

            if IsFallDamage then 
                RespectiveConnection:Enable()
            else 
                RespectiveConnection:Disable()
            end 
        end
    end 

    return Found
end 

return Player