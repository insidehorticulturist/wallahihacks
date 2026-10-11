-- by nqjf and amedote

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local container = require("@Util/container")
local utility = require("../utility")
local GunClient = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Class"):WaitForChild("GunClient"))

local main = {}
main.__index = main
function main.new()
    return setmetatable({
        circle = nil,
        lastClocked = os.clock(),
    }, main)
end

local inaccuracyMagnitude = 5
local inaccuracySpeed = 2

-- tools that keep their normal targeting
local IGNORED_TOOLS = {
    ["Laser Strike"] = true,
    ["Orbital Shield"] = true,
    ["Cruise Missile"] = true,
    ["Rocket Launcher"] = true,
    ["Laser Drill"] = true,
}

local function getRandomBodyPart()
    local roll = math.random()
    if roll <= 0.6 then
        return "HumanoidRootPart"
    else
        return "Head"
    end
end

function main:start()
    local oldMouseInfo = GunClient.GetMouseInfo
    local LocalPlayer = Players.LocalPlayer

    function GunClient.GetMouseInfo(...)
        self.lastClocked = os.clock()

        local character = LocalPlayer.Character
        local tool = character and character:FindFirstChildOfClass("Tool")
        local toolName = tool and tool.Name or ""
        if IGNORED_TOOLS[toolName] then
            return oldMouseInfo(...)
        end

        local result = { oldMouseInfo(...) }

        if Toggles.SilentAim.Value then
            local getCharacter =
                utility.GetClosestPlayer(Options["SilentAim/DrawFovValue"].Value, Toggles["SilentAim/TeamCheck"].Value)

            container.lockedOn = getCharacter
            if getCharacter then
                local bodyPart = getCharacter:FindFirstChild(
                    if Options["SilentAim/BodyParts"].Value == "Random"
                        then getRandomBodyPart()
                        else Options["SilentAim/BodyParts"].Value
                )

                if bodyPart then
                    local offset = Vector3.new(0, 0, 0)
                    local accuracy = Options["SilentAim/AccuracyValue"].Value
                    if accuracy < 100 then
                        local t = tick() * inaccuracySpeed
                        local fluctuation = math.sin(t) * inaccuracyMagnitude
                        local randomNoise = Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1))
                        offset = (randomNoise + Vector3.new(fluctuation, fluctuation, fluctuation))
                            * ((100 - accuracy) / 100)
                    end

                    result[1] = bodyPart
                    result[2] = bodyPart.Position + offset
                end
            end
        else
            container.lockedOn = nil
        end

        return unpack(result)
    end
end

function main:update()
    if os.clock() - self.lastClocked >= 0.3 then
        container.lockedOn = nil
    end
    if Toggles["SilentAim/DrawFov"].Value then
        if self.circle == nil then
            self.circle = utility.circle({ Radius = Options["SilentAim/DrawFovValue"].Value })
            self.circle.Visible = true
        end

        self.circle.Radius = Options["SilentAim/DrawFovValue"].Value
        self.circle.Color = Options["SilentAim/DrawFovColor"].Value
        self.circle.Position = UserInputService.GetMouseLocation(UserInputService)
    else
        if self.circle ~= nil then
            self.circle.Visible = false
            self.circle:Remove()
        end

        self.circle = nil
    end
end

return main
