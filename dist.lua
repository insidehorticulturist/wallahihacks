local mini={cache={}}do do local __modImpl=function()







































local freeThreads= {}
local runCallback=function(
callback, thread, ...)	
callback(...)
	table.insert(freeThreads, thread)
end local yielder=function()	


while true do
		runCallback(coroutine.yield())
	end
end

local Connection = {}
Connection.__index = Connection
local disconnect=function(
self)	
if not self.Connected then
		return
	end
	self.Connected = false

	local next = self._next
	local prev = self._prev

	if next then
		next._prev = prev
	end
	if prev then
		prev._next = next
	end

	local signal = self._signal
	if signal._head == self then
		signal._head = next
	end
end local reconnect=function(

self)	
if self.Connected then
		return
	end
	self.Connected = true

	local signal = self._signal
	local head = signal._head
	if head then
		head._prev = self
	end
	signal._head = self

	self._next = head
	self._prev = false
end

Connection.Disconnect = disconnect
Connection.Reconnect = reconnect

--\\ Signal //--
local Signal = {}
Signal.__index = Signal

-- stylua: ignore
local rbxConnect, rbxDisconnect do
	if task then
		local bindable = Instance.new("BindableEvent")
		rbxConnect = bindable.Event.Connect
		rbxDisconnect = bindable.Event:Connect(function() end).Disconnect
		bindable:Destroy()
	end
end
local connect=function(
self, fn, ...)	
local head = self._head
	local varargs = { ... }
	local cn = setmetatable({
		Connected = true,
		_signal = self,
		_fn = fn,
		_varargs = (#varargs == 0 and{false }or{varargs})[1],
		_next = head,
		_prev = false,
	}, Connection)

	if head then
		head._prev = cn
	end
	self._head = cn

	return cn
end local once=function(

self, fn, ...)	
local cn
	cn = connect(self, function(...)
		disconnect(cn)
		fn(...)
	end, ...)
	return cn
end

local wait = task
and function(self)		
local thread = coroutine.running()
		local cn
		cn = connect(self, function(...)
			disconnect(cn)
			if coroutine.status(thread) == "suspended" then
				task.spawn(thread, ...)
			end
		end)
		return coroutine.yield()
	end
or function(self)		
local thread = coroutine.running()
		local cn
		cn = connect(self, function(...)
			disconnect(cn)
			local passed, message = coroutine.resume(thread, ...)
			if not passed then
				error(message, 0)
			end
		end)
		return coroutine.yield()
	end

local fire = task
and function(self, ...)
		local cn = self._head
		while cn do
			local thread
			if #freeThreads > 0 then
				thread = freeThreads[#freeThreads]
				freeThreads[#freeThreads] = nil
			else
				thread = coroutine.create(yielder)
				coroutine.resume(thread)
			end

			if not cn._varargs then
				task.spawn(thread, cn._fn, thread, ...)
			else
				local args = cn._varargs
				local len = #args
				local count = len
				for _, value in { ... } do
					count =count+ 1
					args[count] = value
				end

				task.spawn(thread, cn._fn, thread, table.unpack(args))

				for i = count, len + 1, -1 do
					args[i] = nil
				end
			end

			cn = cn._next
		end
	end
or function(self, ...)
		local cn = self._head
		while cn do
			local thread
			if #freeThreads > 0 then
				thread = freeThreads[#freeThreads]
				freeThreads[#freeThreads] = nil
			else
				thread = coroutine.create(yielder)
				coroutine.resume(thread)
			end

			if not cn._varargs then
				local passed, message = coroutine.resume(thread, cn._fn, thread, ...)
				if not passed then
					print(string.format("%s\nstacktrace:\n%s", message, debug.traceback()))
				end
			else
				local args = cn._varargs
				local len = #args
				local count = len
				for _, value in { ... } do
					count =count+ 1
					args[count] = value
				end

				local passed, message = coroutine.resume(thread, cn._fn, thread, table.unpack(args))
				if not passed then
					print(string.format("%s\nstacktrace:\n%s", message, debug.traceback()))
				end

				for i = count, len + 1, -1 do
					args[i] = nil
				end
			end

			cn = cn._next
		end
	end
local disconnectAll=function(
self)	
local cn = self._head
	while cn do
		disconnect(cn)
		cn = cn._next
	end
end local destroy=function(

self)	
disconnectAll(self)
	local cn = self.RBXScriptConnection
	if cn then
		rbxDisconnect(cn)
		self.RBXScriptConnection = nil
	end
end
--\\ Constructors

function Signal.new()	
return setmetatable({ _head = false }, Signal)
end

function Signal.wrap(signal)	
local wrapper = setmetatable({ _head = false }, Signal)
	wrapper.RBXScriptConnection = rbxConnect(signal, function(...)
		fire(wrapper, ...)
	end)
	return wrapper
end

--\\ Methods
Signal.Connect = connect
Signal.Once = once
Signal.Wait = wait
Signal.Fire = fire
Signal.DisconnectAll = disconnectAll
Signal.Destroy = destroy

return { new = Signal.new, wrap = Signal.wrap }end function mini.a()local v=mini.cache.a if not v then v={c=__modImpl()}mini.cache.a=v end return v.c end end do local __modImpl=function()-- example script by https://github.com/mstudio45/LinoriaLib/blob/main/Example.lua and modified by deivid
-- You can suggest changes with a pull request or something


local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
	Title = "xd",
	Footer = string.format('not by amedote | %s', tostring(game.PlaceVersion)),
	NotifySide = "Right",
	ShowCustomCursor = false,
})

getgenv().Toggles = Toggles
getgenv().Options = Options

return {
	autoload = function()
		local UISettings = Window:AddTab("UI Settings", "settings")

		-- UI Settings
		local MenuGroup = UISettings:AddLeftGroupbox("Menu", "wrench")

		MenuGroup:AddToggle("KeybindMenuOpen", {
			Default = Library.KeybindFrame.Visible,
			Text = "Open Keybind Menu",
			Callback = function(value)
				Library.KeybindFrame.Visible = value
			end,
		})
		MenuGroup:AddToggle("ShowCustomCursor", {
			Text = "Custom Cursor",
			Default = false,
			Callback = function(Value)
				Library.ShowCustomCursor = Value
			end,
		})
		MenuGroup:AddDropdown("NotificationSide", {
			Values = { "Left", "Right" },
			Default = "Right",

			Text = "Notification Side",

			Callback = function(Value)
				Library:SetNotifySide(Value)
			end,
		})
		MenuGroup:AddDropdown("DPIDropdown", {
			Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
			Default = "100%",

			Text = "DPI Scale",

			Callback = function(Value)
				Value = Value:gsub("%%", "")
				local DPI = tonumber(Value)

				Library:SetDPIScale(DPI)
			end,
		})
		MenuGroup:AddDivider()
		MenuGroup:AddLabel("Menu bind")
			:AddKeyPicker("MenuKeybind", { Default = "Insert", NoUI = true, Text = "Menu keybind" })

		MenuGroup:AddButton("Unload", function()
			Library:Unload()
		end)

		Library.ToggleKeybind = Options.MenuKeybind

		ThemeManager:SetLibrary(Library)
		SaveManager:SetLibrary(Library)

		SaveManager:IgnoreThemeSettings()
		SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

		ThemeManager:SetFolder("MyScriptHub")
		SaveManager:SetFolder("MyScriptHub/specific-game")
		SaveManager:SetSubFolder("specific-place")

		SaveManager:BuildConfigSection(UISettings)
		ThemeManager:ApplyToTab(UISettings)
		SaveManager:LoadAutoloadConfig()
	end,

	Window = Window,
	Library = Library,
	Toggles = Toggles,
	Options = Options,
}
end function mini.b()local v=mini.cache.b if not v then v={c=__modImpl()}mini.cache.b=v end return v.c end end do local __modImpl=function()
local sc = (debug and debug.setconstant) or setconstant
local gc = (debug and debug.getconstants) or getconstants
if not sc or not getgc or not gc then
		return 
end
local pop = game.Players.LocalPlayer.PlayerScripts.PlayerModule.CameraModule.ZoomController.Popper
function Toggle()
    print("toggled")
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

return Toggle end function mini.c()local v=mini.cache.c if not v then v={c=__modImpl()}mini.cache.c=v end return v.c end end do local __modImpl=function()
return {}end function mini.d()local v=mini.cache.d if not v then v={c=__modImpl()}mini.cache.d=v end return v.c end end do local __modImpl=function()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ToolProducer = require(
    ReplicatedStorage:WaitForChild("Client")
        :WaitForChild("Loader")
        :WaitForChild("StructureNetworkingController")
        :WaitForChild("Components")
        :WaitForChild("ToolProducer")
)

local main = {}
main.__index = main

function main.new()
    return setmetatable({}, main)
end

function main:start()
    local o
    o = hookmetamethod(
        game,
        "__namecall",
        LPH_JIT_MAX(function(self, ...)
            if checkcaller() then
                return o(self, ...)
            end

            local nmc = getnamecallmethod()

            if nmc == "Raycast" then
                local character = Players.LocalPlayer.Character
                if
                    Toggles["PORTAFAB/InfiniteRange"].Value
                    and debug.getinfo(3).name == "getMouseInfo"
                    and debug.traceback():find("ContextButtons")
                    and character
                then
                    local result = o(self, ...)

                    if result then
                        return {
                            Instance = result.Instance,
                            Position = character.HumanoidRootPart.Position,
                        }
                    end
                end
            elseif nmc == "GetAttribute" then
                local name = select(1, ...)

                if Toggles.JetPackMods.Value then
                    if name == "MaxThrustTime" then
                        return Options.MaxThrustTime.Value
                    end

                    if name == "CooldownTime" then
                        return Options.CooldownTime.Value
                    end

                    if name == "ThrustPower" then
                        return Options.PowerThrust.Value
                    end
                end
            elseif Toggles.FallDamage.Value and nmc == "TakeDamage" then
                return
            end

            return o(self, ...)
        end)
    )

    Toggles.InstantProduceWeapons:OnChanged(function(bool)
        if bool then
            ToolProducer.SpringPanelConfig = { frequency = 0, dampeningRatio = 2 }
            ToolProducer.AnimationDuration = 0
            ToolProducer.LinearArmConfig = { velocity = 100 }
        else
            ToolProducer.SpringPanelConfig = { frequency = 3, dampeningRatio = 1 }
            ToolProducer.AnimationDuration = 0.25
            ToolProducer.LinearArmConfig = { velocity = 1 }
        end
    end)
end

return main
end function mini.e()local v=mini.cache.e if not v then v={c=__modImpl()}mini.cache.e=v end return v.c end end do local __modImpl=function()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local container = mini.d()

local SpawnPointController =
    require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("Loader"):WaitForChild("SpawnPointController"))
local SpawnRequest = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("SpawnRequest")
local UpdateSpawnPads = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("UpdateSpawnPads")

local main = {}
main.__index = main

function main.new()
    return setmetatable({
        currentSpawn = nil,
    }, main)
end

function main:start()
    local this = self
    local oldSelect = SpawnPointController._select

    function SpawnPointController._select(...)
        local hasIndex = select(2, ...)

        if hasIndex then
            this.currentSpawn = select(2, ...)
        end

        return oldSelect(...)
    end
    container.instantTPCall:Connect(function()
        if this.currentSpawn == nil then
            local randomSpawn = SpawnPointController.padList[math.random(1, #SpawnPointController.padList)]

            if randomSpawn then
                SpawnRequest:InvokeServer(randomSpawn.Index, false)
            end
            return
        end

        SpawnRequest:InvokeServer(this.currentSpawn, false)
    end)

    container.instantRespawnCall:Connect(function()
        if this.currentSpawn == nil then
            local randomSpawn = SpawnPointController.padList[math.random(1, #SpawnPointController.padList)]

            if randomSpawn then
                SpawnRequest:InvokeServer(randomSpawn.Index, true)
            end
            return
        end

        SpawnRequest:InvokeServer(this.currentSpawn, true)
    end)

    Options.SelectedPadList:OnChanged(function(value)
        this.currentSpawn = value
    end)
local setUIList=function(
pads)        
local withIndex = {}

        for _, v in pads do
            local tot = v.TeleportAvailabilityLevel or v.AvailabilityLevel

            if tot >= 1 then
                table.insert(withIndex, v.Index)
            end
        end

        Options.SelectedPadList:SetValues(withIndex)
end
    
UpdateSpawnPads.OnClientEvent:Connect(function(pads)
        setUIList(pads)
    end)

    if Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait() then
        setUIList(SpawnPointController.padList)
    end
end

function main:update()
    container.selectedSpawn = self.currentSpawn
end

return main
end function mini.f()local v=mini.cache.f if not v then v={c=__modImpl()}mini.cache.f=v end return v.c end end do local __modImpl=function()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local StructureUtil =
    require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utilities"):WaitForChild("StructureUtil"))

local ContextButtonRemote =
    ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("ContextButton")

local main = {}
main.__index = main
local getCurrentBore=function()    

local mouseLocation = UserInputService:GetMouseLocation()
    local camera = workspace.CurrentCamera
    local ray = camera:ScreenPointToRay(mouseLocation.X, mouseLocation.Y)

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances =
        { camera, CollectionService:GetTagged("ContextHintRaycastIgnore"), Players.LocalPlayer.Character }

    local result = workspace:Raycast(ray.Origin, ray.Direction * 9999, params)
    if result then
        return StructureUtil:getRootModel(result.Instance)
    end

    return nil
end local activateButton=function(

button)    
if button then
        button:Fire()
        ContextButtonRemote:FireServer(button)
    end
end

function main.new()
    return setmetatable({}, main)
end

function main:start()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or not Toggles.AutoInteractBore.Value then
            return
        end

        local bore = getCurrentBore()

        if not bore then
            return
        end

        local TargetButton = bore:FindFirstChild("TargetButton")
        local PowerButton = bore:FindFirstChild("PowerButton")

        if input.UserInputType == Enum.UserInputType.MouseButton1 and TargetButton then
            ContextActionService:UnbindAction("SelectTarget")
            activateButton(TargetButton.ContextButton)
            ContextActionService:UnbindAction("SelectTarget")
        elseif input.KeyCode == Enum.KeyCode.E and PowerButton then
            activateButton(PowerButton.ContextButton)
        end
    end)
end
return main
end function mini.g()local v=mini.cache.g if not v then v={c=__modImpl()}mini.cache.g=v end return v.c end end do local __modImpl=function()
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
end function mini.h()local v=mini.cache.h if not v then v={c=__modImpl()}mini.cache.h=v end return v.c end end do local __modImpl=function()
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CurrentCamera = workspace.CurrentCamera
local get=function(
types)    
local ok = (getmodules
and{getmodules
}or{function()
            local format = {}

            for _, v in game:GetDescendants() do
                if IsA(v, "ModuleScript") then
                    table.insert(format, v)
                end
            end

            return format
        end
})[1]
    for _, module in ok() do
        if module.Name == types then
            return require(module)
        end
    end

    return
end local GetClosestPlayer=function(

fovRadius, teamCheck)    
local mousePos = UserInputService:GetMouseLocation()
    local fovSq = (fovRadius or 300) ^ 2

    local closestPlayer = nil
    local closestDistSq = fovSq

    for _, player in ipairs(Players:GetPlayers()) do
        if teamCheck then
            if player.Team == Players.LocalPlayer.Team then
                return
            end
        end

        if player == Players.LocalPlayer then
            continue
        end

        local character = player.Character
        if not character then
            continue
        end

        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
        if not (humanoid and humanoid.Health > 0) then
            continue
        end

        local rootPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            continue
        end

        local screenPos, onScreen = CurrentCamera:WorldToScreenPoint(rootPart.Position)
        if not onScreen then
            continue
        end

        local dx, dy = screenPos.X - mousePos.X, screenPos.Y - mousePos.Y
        local distSq = dx * dx + dy * dy

        if distSq < closestDistSq then
            closestDistSq = distSq
            closestPlayer = player
        end
    end

    if closestPlayer then
        return closestPlayer.Character, math.sqrt(closestDistSq)
    end
    return nil, nil
end local circle=function(

info)    
local circlez = Drawing.new("Circle")
    circlez.Position = info.Position or Vector2.new(150, 150)
    circlez.Radius = info.Radius or 20
    circlez.Filled = false
    circlez.Thickness = info.Thickness or 2

    return circlez
end local label=function(

info)    
local text = Drawing.new("Text")
    text.Text = info.Text or "Hello, World!"
    text.Position = info.Position or Vector2.new(150, 150)
    text.Color = info.Color or Color3.new(0.968627, 0.972549, 0.968627)
    text.Size = 18
    text.Font = Drawing.Fonts.Monospace
    text.Visible = true

    return text
end local square=function(

info)    
local q = Drawing.new("Square")
    q.Visible = info.Visible or false
    q.Transparency = info.Transparency or 1
    q.Color = info.Color or Color3.fromRGB(0, 0, 0)

    q.Thickness = info.Thickness or 1
    q.Filled = info.Filled or false
    return q
end local line=function(

info)    
local l = Drawing.new("Line")
    l.Visible = info.Visible or false
    l.Transparency = info.Transparency or 1
    l.Color = info.Color or Color3.fromRGB(0, 0, 0)

    l.Thickness = info.Thickness or 1
    return l
end local isAliveModel=function(

character)    
if character and character.IsDescendantOf(character, workspace) and character.PrimaryPart ~= nil then
        return character
    end

    return false
end local ActivateButton=function(

button)	
game:GetService('ReplicatedStorage')
		:WaitForChild('Shared')
		:WaitForChild('Remotes')
		:WaitForChild('ContextButton')
		:FireServer(button)
end

return {
    get = get,
    GetClosestPlayer = GetClosestPlayer,
    circle = circle,
    label = label,
    square = square,
    line = line,
    isAliveModel = isAliveModel,
    ActivateButton = ActivateButton
}
end function mini.i()local v=mini.cache.i if not v then v={c=__modImpl()}mini.cache.i=v end return v.c end end do local __modImpl=function()
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local container = mini.d()
local utility = mini.i()
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
local getRandomBodyPart=function()    

local roll = math.random()
    if roll <= 0.6 then
        return "HumanoidRootPart"
    else
        return "Head"
    end
end

function main:start()
    local oldMouseInfo = GunClient.GetMouseInfo

    function GunClient.GetMouseInfo(...)
        self.lastClocked = os.clock()
        local getCharacter =
            utility.GetClosestPlayer(Options["SilentAim/DrawFovValue"].Value, Toggles["SilentAim/TeamCheck"].Value)

        local result = { oldMouseInfo(...) }

        if Toggles.SilentAim.Value then
            container.lockedOn = getCharacter
            if getCharacter then
                local bodyPart = getCharacter:FindFirstChild(
(Options["SilentAim/BodyParts"].Value == "Random"
and{(getRandomBodyPart()
)}or{(Options["SilentAim/BodyParts"].Value
)})[1]                )

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
        else
            self.circle.Radius = Options["SilentAim/DrawFovValue"].Value
            self.circle.Color = Options["SilentAim/DrawFovColor"].Value
            self.circle.Position = UserInputService.GetMouseLocation(UserInputService)
        end
    else
        if self.circle ~= nil then
            self.circle.Visible = false
            self.circle:Remove()
        end

        self.circle = nil
    end
end

return main
end function mini.j()local v=mini.cache.j if not v then v={c=__modImpl()}mini.cache.j=v end return v.c end end do local __modImpl=function()
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local container = mini.d()

local damageindicator = {}
damageindicator.__index = damageindicator

function damageindicator.new()
    return setmetatable({}, damageindicator)
end
local applyDamageVisual=function(
character)    
local humanoid = character:WaitForChild("Humanoid")
    local lastHealth = humanoid.Health

    humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        local currentHealth = humanoid.Health

        if currentHealth < lastHealth and container.lockedOn == nil then
            local foundHighlight = character:FindFirstChild("xaaaaaa")
            if foundHighlight then
                foundHighlight:Destroy()
            end

            local highlight = Instance.new("Highlight")
            highlight.FillColor = Options.DamageIndicatorColor.Value
            highlight.Parent = character
            highlight.Name = "xaaaaaa"
            highlight.FillTransparency = 0.05

            TweenService:Create(highlight, TweenInfo.new(1), {
                FillTransparency = 1,
                OutlineTransparency = 1,
            }):Play()

            task.delay(1, function()
                highlight:Destroy()
            end)
        end

        lastHealth = currentHealth
    end)
end

function damageindicator:start()
    for _, player in Players:GetPlayers() do
        applyDamageVisual(player.Character)
        player.CharacterAdded:Connect(applyDamageVisual)
    end

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(applyDamageVisual)
    end)
end

return damageindicator
end function mini.k()local v=mini.cache.k if not v then v={c=__modImpl()}mini.cache.k=v end return v.c end end do local __modImpl=function()
local Players = game:GetService("Players")
local CurrentCamera = workspace.CurrentCamera

local container = mini.d()
local utility = mini.i()

local LerpColorModule = loadstring(game:HttpGet("https://pastebin.com/raw/wRnsJeid"))()
local HealthBarLerp = LerpColorModule:Lerp(Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0))

local main = {}
main.__index = main

function main.new()
    return setmetatable({
        entities = {},
    }, main)
end
local DecimalToPercentage=function(
decimalValue)    
decimalValue = math.clamp(decimalValue, 0, 1)
    local percent = decimalValue * 100
    return math.floor(percent)
end

function main:addEsp(player)
    local label = utility.label({})
    label.Center = true

    local highlight = Instance.new("Highlight")

    local healthBar = utility.line({ Color = Color3.fromRGB(0, 255, 0), Thickness = 1 })
    local Bar = utility.line({ Color = Color3.fromRGB(10, 10, 10), Thickness = 3, Transparency = 0.4 })

    local prevhealth = nil

    local Box_Lines = {}
    for i = 1, 8 do
        Box_Lines[i] = utility.line({})
    end
local Box_Vis=function(
state, mode)        
if state == false then
            for i = 1, 8 do
                Box_Lines[i].Visible = false
            end
        elseif state and mode == 1 then
            for i = 1, 4 do
                Box_Lines[i].Visible = true
            end
            for i = 5, 8 do
                Box_Lines[i].Visible = false
            end
        elseif state and mode == 2 then
            for i = 1, 8 do
                Box_Lines[i].Visible = true
            end
        end
end local Lines_Color=function(

col)        
for i = 1, #Box_Lines do
            Box_Lines[i].Color = col
        end
end
    
return {
        update = function()
            local character = player.Character
            if not utility.isAliveModel(Players.LocalPlayer.Character) then
                return
            end

            local localrootpart = Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                or Players.LocalPlayer.Character.PrimaryPart
            local root_part = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
            local hum = character:FindFirstChildOfClass("Humanoid")

            if localrootpart and root_part then
                local root_pos, onscreen = CurrentCamera:WorldToViewportPoint(root_part.Position)
                local dist = (root_part.Position - localrootpart.Position).magnitude

                if onscreen then
                    local ratio = 2500 / root_pos.Z

                    local newsize_x = ratio / 2
                    local newsize_y = ratio * 1.75 / 2

                    local root_x = root_pos.X
                    local root_y = root_pos.Y

                    label.Position = Vector2.new(root_x, root_y - newsize_y - label.TextBounds.Y)
                    label.Text = ""

                    if Options["playersVisualLists"].Value["Name"] then
                        label.Text = character.Name
                    end

                    if Options["playersVisualLists"].Value["Health"] then
                        label.Text = string.format('%s%% %s', tostring(math.round(hum.Health / hum.MaxHealth * 100)), tostring(label.Text))
                        
local Hum_Health = hum.Health
                        local Hum_MaxHealth = hum.MaxHealth

                        local offsetX = math.clamp(math.round(200 / root_pos.Z), 4, 8)

                        local Right = root_x + newsize_x
                        local Top = root_y - newsize_y
                        local Bottom = root_y + newsize_y

                        local barPos = Right + offsetX

                        Bar.From = Vector2.new(barPos, Top)
                        Bar.To = Vector2.new(barPos, Bottom)

                        local HealthRatio = Hum_Health / Hum_MaxHealth
                        local Length = math.abs((Bottom - 1) - (Top + 1))

                        local HealthLength = Length * HealthRatio
                        healthBar.From = Vector2.new(barPos, Bottom - 1 - HealthLength)
                        healthBar.To = Vector2.new(barPos, Bottom - 1)

                        if Hum_Health ~= prevhealth then
                            healthBar.Color = HealthBarLerp(HealthRatio)
                            prevhealth = Hum_Health
                        end

                        healthBar.Visible = true
                        Bar.Visible = true
                    else
                        healthBar.Visible = false
                        Bar.Visible = false
                    end

                    if Options["playersVisualLists"].Value["Iridium"] then
                        pcall(function()
                            label.Text = string.format(' %s Iridium: %s', tostring(label.Text), tostring(DecimalToPercentage(
                                character.IridiumTank.Indicator.IridiumMeter.Mesh.Scale.Y
                            )))                        
end)
                    end

                    if Options["playersVisualLists"].Value["Distance"] then
                        label.Text = string.format('%s (%s)', tostring(label.Text), tostring(math.round(dist)))                    
end

                    if Options["playersVisualLists"].Value["Box"] then
                        local Dir1 = Vector2.new(ratio / 4, 0)
                        local Dir2 = Vector2.new(0, ratio / 4)

                        local TL = Vector2.new(root_x - newsize_x, root_y - newsize_y)
                        local TR = Vector2.new(root_x + newsize_x, root_y - newsize_y)
                        local BL = Vector2.new(root_x - newsize_x, root_y + newsize_y)
                        local BR = Vector2.new(root_x + newsize_x, root_y + newsize_y)

                        Box_Lines[1].From = TL
                        Box_Lines[1].To = TL + Dir1

                        Box_Lines[2].From = TL
                        Box_Lines[2].To = TL + Dir2

                        Box_Lines[3].From = TR
                        Box_Lines[3].To = TR - Dir1

                        Box_Lines[4].From = TR
                        Box_Lines[4].To = TR + Dir2

                        Box_Lines[5].From = BL
                        Box_Lines[5].To = BL + Dir1

                        Box_Lines[6].From = BL
                        Box_Lines[6].To = BL - Dir2

                        Box_Lines[7].From = BR
                        Box_Lines[7].To = BR - Dir1

                        Box_Lines[8].From = BR
                        Box_Lines[8].To = BR - Dir2

                        if container.lockedOn == player.Character then
                            Lines_Color(Options["SilentAim/Color"].Value)
                        else
                            Lines_Color(
(Toggles["playersVisualUseTeamColor"].Value
and{(player.TeamColor.Color
)}or{(Options["BoxColor"].Value
)})[1]                            )
                        end

                        if Box_Lines[8].Visible == false or Box_Lines[1].Visible == false then
                            Box_Vis(true, 2)
                        end
                    else
                        Box_Vis(false)
                    end

                    if Options["playersVisualLists"].Value["Highlight"] then
                        highlight.Name = "penisHacks"
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

                        if container.lockedOn == player.Character then
                            highlight.FillColor = Options["SilentAim/Color"].Value
                        else
                            highlight.FillColor = (Toggles["playersVisualUseTeamColor"].Value
and{(player.TeamColor.Color
)}or{(Options["BoxColor"].Value
)})[1]                        end

                        highlight.FillTransparency = 0.4
                        highlight.Parent = player.Character
                        highlight.Enabled = true
                    else
                        highlight.Enabled = false
                    end

                    label.Visible = true

                    if container.lockedOn == player.Character then
                        label.Color = Options["SilentAim/Color"].Value
                    else
                        label.Color = (Toggles["playersVisualUseTeamColor"].Value
and{(player.TeamColor.Color
)}or{(Options.LabelColor.Value
)})[1]                    end
                else
                    Box_Vis(false)
                    label.Visible = false
                    Bar.Visible = false
                    healthBar.Visible = false
                end
            end
        end,

        destroy = function()
            Box_Vis(false)
            label.Visible = false
            Bar.Visible = false
            healthBar.Visible = false

            label:Remove()
            Bar:Remove()
            healthBar:Remove()

            for i = 1, #Box_Lines do
                Box_Lines[i]:Remove()
            end
        end,
    }
end

function main:update()
    if Toggles.playersVisual.Value then
        for _, player in Players:GetPlayers() do
            if player == Players.LocalPlayer then
                continue
            end

            if Toggles.playersVisualTeamcheck.Value then
                if player.Team == Players.LocalPlayer.Team then
                    continue
                end
            end

            local character = player.Character

            if character and self.entities[character] == nil then
                self.entities[character] = self:addEsp(player)
            end
        end
    else
        for key, object in self.entities do
            object.destroy()
            self.entities[key] = nil
        end
    end

    for key, object in self.entities do
        if key and not key.IsDescendantOf(key, workspace) then
            self.entities[key] = nil
            object.destroy()
        end
    end

    for _, object in self.entities do
        object.update()
    end
end

return main
end function mini.l()local v=mini.cache.l if not v then v={c=__modImpl()}mini.cache.l=v end return v.c end end do local __modImpl=function()
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local ArtilleryArc = {}
ArtilleryArc.__index = ArtilleryArc

local DEFAULTS = {
	projectileSpeed = 137.23,
	totalDuration = 5,
	resolution = 30,
}

function ArtilleryArc.new()
	local self = setmetatable({}, ArtilleryArc)

	self.player = Players.LocalPlayer
	self.barrel = nil
	self.arcModel = nil
	self.arcParts = {}
	self.highlight = nil
	self.active = false

	self.projectileSpeed = DEFAULTS.projectileSpeed
	self.totalDuration = DEFAULTS.totalDuration
	self.resolution = DEFAULTS.resolution

	return self
end

function ArtilleryArc:_findArtilleryReference()
	local plr = self.player
	if not plr then
		return nil
	end
	local character = plr.Character
	if not character then
		return nil
	end

	for _, inst in pairs(character:GetDescendants()) do
		if inst.Name == "ArtilleryReference" and inst:IsA("ObjectValue") and inst.Value then
			return inst.Value
		end
	end

	return nil
end

function ArtilleryArc:_buildArc(foundRef)
	if not foundRef then
		return
	end
	local tilt = foundRef:FindFirstChild("TiltAssembly")
	local barrel = tilt and tilt:FindFirstChild("Barrel")

	if not barrel then
		return
	end

	if self.arcModel then
		self:_destroyArc()
	end

	self.barrel = barrel

	local arcModel = Instance.new("Model")
	arcModel.Name = "\255"
	arcModel.Parent = self.barrel

	local highlight = Instance.new("Highlight")

	highlight.Name = "ArcHighlight"
	highlight.Adornee = arcModel
	highlight.FillColor = Color3.fromRGB(255, 255, 0)
	highlight.FillTransparency = 0
	highlight.OutlineColor = Color3.new(1, 1, 1)
	highlight.OutlineTransparency = 1
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Parent = arcModel

	self.arcModel = arcModel
	self.highlight = highlight

	for i = 1, self.resolution do
		local part = Instance.new("Part")
		part.Name = "\255"
		part.Anchored = true
		part.CanCollide = false
		part.Size = Vector3.new(0.1, 0.1, 1)
		part.Material = Enum.Material.Neon
		part.Color = Color3.fromRGB(30, 160, 36)

		part.Parent = arcModel
		table.insert(self.arcParts, part)
	end

	self.active = true
end

function ArtilleryArc:_destroyArc()
	if self.arcModel then
		self.arcModel:Destroy()
	end
	self.arcModel = nil
	self.highlight = nil
	self.arcParts = {}
	self.barrel = nil
	self.active = false
end

function ArtilleryArc:update(dt)
	if not Toggles or not Toggles.artyVisual then
		return
	end

	if not Toggles.artyVisual then
		if self.active then
			self:_destroyArc()
		end
		return
	end

	local foundRef = self:_findArtilleryReference()

	if not foundRef then
		if self.active then
			self:_destroyArc()
		end
		return
	end

	if self.active and self.barrel and self.barrel:IsDescendantOf(foundRef) == false then
		self:_destroyArc()
	end
	if not self.active then
		self:_buildArc(foundRef)
	end

	if not self.active or not self.barrel then
		return
	end

	local gravity = Vector3.new(0, -Workspace.Gravity, 0)
	local originCFrame = self.barrel.CFrame
	local startPosition = originCFrame.Position
	local direction = originCFrame.LookVector
	if direction.Magnitude == 0 then
		return
	end
	local velocity = direction.Unit * self.projectileSpeed

	local points = {}
	for i = 0, self.resolution do
		local t = (i / self.resolution) * self.totalDuration
		points[i + 1] = startPosition + velocity * t + 0.5 * gravity * t * t
	end


	local sizeVal = 1
	for i = 1, self.resolution do
		local a, b = points[i], points[i + 1]
		if a and b then
			local dir = b - a
			local distance = dir.Magnitude
			if distance > 0.0001 then
				local midPoint = (a + b) * 0.5
				local part = self.arcParts[i]
				if part then
					part.Size = Vector3.new(sizeVal, sizeVal, distance)
					local ok, cf = pcall(function()
						return CFrame.lookAt(midPoint, b)
					end)
					if ok and cf then
						part.CFrame = cf
					end
				end
			end
		end
	end
end

function ArtilleryArc:destroy()
	self:_destroyArc()
	self.player = nil
end

return ArtilleryArc end function mini.m()local v=mini.cache.m if not v then v={c=__modImpl()}mini.cache.m=v end return v.c end end do local __modImpl=function()
local main = {}
main.__index = main

function main.new()
    return setmetatable({}, main)
end

local validNames = {
    ["Arc Turret"] = true,
    ["Turret"] = true,
    ["Fabricator"] = true,
    ["Automechanic"] = true,
    ["Boost Pad"] = true,
    ["Observer"] = true,
    ["Spatial Anchor"] = true,
    ["Spawn Point"] = true,
    ["Shield Generator"] = true,
    ["Point Defense"] = true
}
local roundRotationTo15Degrees=function(
cf)    
local xRot, yRot, zRot = cf:ToEulerAnglesXYZ()
    local positionOnly = CFrame.new(cf.Position)
local roundTo15=function(angle)        
return math.rad(math.round(math.deg(angle) / 15) * 15) 
end    
return positionOnly * CFrame.Angles(roundTo15(xRot), roundTo15(yRot), roundTo15(zRot))
end local computePlacementInfo=function(

capModel, flange)    
local capPrimary = capModel:FindFirstChildWhichIsA('BasePart')
    if not capPrimary then
        return
    end 
    local heightOffset = capPrimary.Size.Y / 2 -0.55
    local baseCFrame = flange.CFrame * CFrame.new(0.6, heightOffset, 0)
    local snappedCFrame = roundRotationTo15Degrees(baseCFrame)
    local flangeRotation = flange.CFrame - flange.CFrame.Position
    local rotatedCFrame = flangeRotation * CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(math.rad(-90), 0, 0) 
    rotatedCFrame = CFrame.new(snappedCFrame.Position) * rotatedCFrame 
    return {
        CFrame = flange.CFrame:ToObjectSpace(rotatedCFrame),
        BasePart = flange, 
    } 
end local placeDistributorCap=function(

turret)    
local pipeFemale = turret:WaitForChild('PipeFemale', 5)
    if not pipeFemale then
        return
    end
    local flange = pipeFemale:WaitForChild('FemaleFlange', 5)
    if not flange then
        return
    end
    local capModel = game:GetService("ReplicatedStorage").Server.Structures.Iridium.Special.Tech:WaitForChild("Distributor Cap"):Clone()
    local placementInfo = computePlacementInfo(capModel, flange)
    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("PlaceStructure"):FireServer( "Distributor Cap", placementInfo, 'FemaleFlange', flange ) 
end

function DCap(structure)

    if not validNames[structure.Name] then
        return
    end
    if structure:GetAttribute("Builder") ~= game:GetService("Players").LocalPlayer.Name then
        return
    end
  
    placeDistributorCap(structure)
end

function main:start(structure)
    if not Toggles and Toggles.AutoDCap then return end
    DCap(structure)
end



function main:stop()

end



return main
end function mini.n()local v=mini.cache.n if not v then v={c=__modImpl()}mini.cache.n=v end return v.c end end do local __modImpl=function()--core/autoshield.luau


local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Util = mini.i()

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

return StructurePlaced end function mini.o()local v=mini.cache.o if not v then v={c=__modImpl()}mini.cache.o=v end return v.c end end do local __modImpl=function()-- FloorPartModule.lua

local main = {}
main.__index = main

function main.new(options)
	local self = setmetatable({}, main)
	self.player = game.Players.LocalPlayer
	self.part = nil
	self.hrp = nil
	return self
end

function main:start()
	-- Reattach every time the player respawns
	game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
		self:setup(character)
	end)

	-- If the character already exists, start immediately
	if game.Players.LocalPlayer.Character then
		self:setup(game.Players.LocalPlayer.Character)
	end
end

function main:setup(character)
	local hrp = character:WaitForChild("HumanoidRootPart")

	-- Create the circular (cylindrical) part
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Cylinder
	part.Parent = workspace
	part.Color = Color3.fromRGB(255, 0, 0)
	part.CanCollide = false
	part.Anchored = true
	part.Transparency = 1 -- start invisible

	self.part = part
	self.hrp = hrp

	task.spawn(function()
		while character and character.Parent do
			self:update()
			task.wait()
		end
	end)
end

function main:update()
	if not Toggles.HeightLimitESP then 
		self.part.Transparency = 1
		return end
	if not self.part or not self.hrp then return end
	-- Update size from options
	if Options.HeightlimitSize.Value then
		self.part.Size = Vector3.new(0.1,Options.HeightlimitSize.Value,Options.HeightlimitSize.Value)
	end

	-- Update position while keeping it rotated flat
	local pos = self.hrp.Position
	self.part.CFrame = CFrame.new(pos.X, 252, pos.Z) * CFrame.Angles(0, 0, math.rad(90))

	-- Update fade distance from options
	local fadeDistance = 15
	local fadeSpeed =  0.1

	local distance = (self.hrp.Position - self.part.Position).Magnitude
	local targetTransparency = distance < fadeDistance and math.clamp(distance / fadeDistance, 0, 1) or 1
	self.part.Color = Options.HeighLimitColor.Value
	-- Smooth transparency transition
	self.part.Transparency = self.part.Transparency + (targetTransparency - self.part.Transparency) * fadeSpeed
end

return main
end function mini.p()local v=mini.cache.p if not v then v={c=__modImpl()}mini.cache.p=v end return v.c end end end
loadstring([[
    function LPH_NO_VIRTUALIZE(f) return f end;
	function LPH_JIT(f) return f end;
	function LPH_JIT_MAX(f) return f end;
	function LPH_NO_UPVALUES(f) return f end;
]])()

local RunService = game:GetService("RunService")

local signal = mini.a()
local obsidian = mini.b()
local nccam = mini.c()

local LocalTab = obsidian.Window:AddTab("Local Player", "gamepad-2")
local AimbotTab = obsidian.Window:AddTab("Aimbot", "aperture")
local AutoTab = obsidian.Window:AddTab("Autos", "monitor-cog")
local VisualTab = obsidian.Window:AddTab("Visual Tab", "brain")

do
    local instantTPCall = signal.new()
    local instantRespawnCall = signal.new()

    local camera = LocalTab:AddRightGroupbox("Camera")
    camera:AddLabel("Noclip Camera"):AddKeyPicker("NcCam", {
        Text = "Noclip Camera",
        Mode = "Press",
        Callback = function()
            nccam()
        end,
    })

    local JetpackMods = LocalTab:AddLeftGroupbox("Jetpack")
    JetpackMods:AddCheckbox("JetPackMods", { Text = "Enable Jetpack Mods" })
    JetpackMods:AddSlider("MaxThrustTime", { Text = "Set Max Thrust Time", Default = 5, Min = 1, Max = 100 })
    JetpackMods:AddSlider(
        "CooldownTime",
        { Text = "Set Cooldown Time", Default = 0.05, Min = 0.01, Max = 1, Rounding = 2 }
    )
    JetpackMods:AddSlider("PowerThrust", { Text = "Set Power Thrust", Default = 17, Min = 1, Max = 100 })

    local UtilityMods = LocalTab:AddLeftGroupbox("Utility")
    UtilityMods:AddCheckbox("FallDamage", { Text = "No Fall Damage" })
    UtilityMods:AddCheckbox("InstantProduceWeapons", { Text = "Instant Produce Weapons" })
    UtilityMods:AddCheckbox("AutoInteractBore", { Text = "Auto Interact Bore" })

    local PortafabMods = LocalTab:AddLeftGroupbox("Portafab")
    PortafabMods:AddCheckbox(
        "PORTAFAB/InfiniteRange",
        { Text = "Infinite Context Range", FormatDisplayValue = function() end }
    )

    -- PortafabMods:AddCheckbox(
    --     "PORTAFAB/InfiniteBuildRange",
    --     { Text = "Infinite Build Range", FormatDisplayValue = function() end }
    -- )

    PortafabMods:AddCheckbox("PORTAFAB/ExtendPipeHitbox", { Text = "Extend Pipe Hitbox" })
    PortafabMods:AddSlider(
        "PORTAFAB/ExtendPipeHitboxSize",
        { Text = "Set Hitbox Size", Default = 1.9, Min = 1.9, Max = 5, Rounding = 2, Tooltip = "2.5 to 3.5 Is good" }
    )

    local SpawnPointMods = LocalTab:AddRightGroupbox("Spawn Point")
    local selectedSpawnLabel = SpawnPointMods:AddLabel("Selected:")
    SpawnPointMods:AddDropdown("SelectedPadList", {
        Text = "Select Spawn",
        Multi = false,
        FormatDisplayValue = function(value)
            return string.format('S%s', tostring(value))        
end,
    })
    SpawnPointMods:AddButton("Instant Teleport", function()
        instantTPCall:Fire()
    end)
    SpawnPointMods:AddButton("Instant Respawn", function()
        instantRespawnCall:Fire()
    end)
    SpawnPointMods:AddLabel("Instant Teleport Keybind"):AddKeyPicker("InstantTPKeybind", {
        Text = "Instant Teleport",
        Mode = "Toggle",
        Callback = function()
            instantTPCall:Fire()
        end,
    })
    SpawnPointMods:AddLabel("Instant Respawn Keybind"):AddKeyPicker("InstantRespawnKeybind", {
        Text = "Instant Respawn",
        Mode = "Toggle",
        Callback = function()
            instantRespawnCall:Fire()
        end,
    })

    local SilentAimSection = AimbotTab:AddLeftGroupbox("Silent Aim")
    SilentAimSection:AddCheckbox("SilentAim", { Text = "Silent Aim" }):AddKeyPicker("SilentAimKey", {
        Text = "Silent Aim",
        Mode = "Hold",
        SyncToggleState = true,
    })
    SilentAimSection:AddDropdown(
        "SilentAim/BodyParts",
        { Text = "Select BodyPart", Default = "Head", Values = { "Head", "Random", "HumanoidRootPart" }, Multi = false }
    )
    SilentAimSection:AddCheckbox("SilentAim/TeamCheck", { Text = "Teamcheck" })
    SilentAimSection:AddCheckbox("SilentAim/DrawFov", { Text = "Draw FOV" }):AddColorPicker("SilentAim/DrawFovColor", {
        Default = Color3.fromRGB(255, 255, 255),
        Title = "Draw FOV Color",
        Transparency = 0,
    })
    SilentAimSection:AddSlider("SilentAim/DrawFovValue", { Text = "Set FOV", Default = 425, Min = 1, Max = 1000 })
    SilentAimSection:AddSlider("SilentAim/AccuracyValue", { Text = "Set Accuracy", Default = 100, Min = 1, Max = 100 })
    SilentAimSection:AddLabel("Locked on Color")
        :AddColorPicker("SilentAim/Color", { Default = Color3.fromRGB(255, 0, 0), Title = "locked on color" })


    local AutoStuff = AutoTab:AddLeftGroupbox("Auto")
    AutoStuff:AddCheckbox("AutoDCap", {Text = "Auto DCap"})
    AutoStuff:AddCheckbox("AutoShield", {Text = "AutoShield", Tooltip = "Automatically turns on shields and anchors when placed"})
    -- local SpamSection = AutoTab:AddLeftGroupbox("Spam")
    -- -- SpamSection:AddDropdown(
    -- --     "SelectSpam",
    -- --     { Text = "Select Spam", Values = { "Laser Strikes", "Orbital Shields", "Cruise Missile" } }
    -- -- )
    -- -- SpamSection:AddCheckbox("ProduceSpam", { Text = "Produce Spam" })
    -- -- SpamSection:AddCheckbox("AutoPickUp", { Text = "Auto Pick up Tool" })

    -- local UpgradeRushSection = AutoTab:AddRightGroupbox("Auto Upgrade Rush")
    -- UpgradeRushSection:AddCheckbox("AutoSortTools", { Text = "Auto Sort Tools" })
    -- UpgradeRushSection:AddCheckbox("ProduceSetUpWalk", { Text = "Walk-to-produce" })
    -- UpgradeRushSection:AddCheckbox("WalkToCollect", { Text = "Walk-to-collect" })
    -- UpgradeRushSection:AddCheckbox("InstantUpgrade", { Text = "Instant Upgrade" })

    -- local UtilitySection = AutoTab:AddLeftGroupbox("Utility")

    local ArtillerySection = VisualTab:AddLeftGroupbox("Artillery")
    ArtillerySection:AddCheckbox("artyVisual", { Text = "Arty Trajectory Visual" })
    -- ArtillerySection:AddLabel("Artillery Color"):AddColorPicker("artyVisualColor", {
    --     Default = Color3.fromRGB(60, 255, 0),
    --     Title = "Artillery Color",
    --     Transparency = 0,
    -- })
    -- ArtillerySection:AddSlider(
    --     "artyVisualSize",
    --     { Text = "Set Arty Size", Default = 0.1, Min = 0.05, Max = 5, Rounding = 2 }
    -- )

    local PlayerVisualSection = VisualTab:AddRightGroupbox("Players")
    PlayerVisualSection:AddCheckbox("playersVisual", { Text = "Players Visual" })
    PlayerVisualSection:AddDropdown("playersVisualLists", {
        Text = "Select to ESP",
        Default = { "Highlight", "Name", "Health", "Distance", "Box" },
        Values = {
            "Iridium",
            "Highlight",
            "Box",
            "Health",
            "Name",
            "Distance",
            "Tool",
        },
        Multi = true,
    })
    PlayerVisualSection:AddLabel("Label Color")
        :AddColorPicker("LabelColor", { Title = "Label Color", Default = Color3.fromRGB(255, 255, 255) })
    PlayerVisualSection:AddLabel("Box Color")
        :AddColorPicker("BoxColor", { Title = "Box Color", Default = Color3.fromRGB(119, 255, 28) })
    PlayerVisualSection:AddCheckbox("playersVisualUseTeamColor", { Text = "Use Team Color" })
    PlayerVisualSection:AddCheckbox("playersVisualTeamcheck", { Text = "Teamcheck" })

    local UtilityVisualSection = VisualTab:AddLeftGroupbox("Utilities")
    UtilityVisualSection:AddCheckbox("DamageIndicator", { Text = "Damage Indicator" })
        :AddColorPicker(
            "DamageIndicatorColor",
            { Title = "Damage Indicator Color", Default = Color3.fromRGB(255, 0, 0) }
        )
    UtilityVisualSection:AddCheckbox("HeightLimitESP", { Text = "HeightLimit Esp" })
        :AddColorPicker(
            "HeighLimitColor",
            { Title = "Height ESP Color", Default = Color3.fromRGB(255, 0, 0) }
        )
    
    UtilityVisualSection:AddSlider("HeightlimitSize", { Text = "Height Limit ESP Size", Default = 2, Min = 1, Max = 30 })


    

    do
        local container = mini.d()

        local main = mini.e().new()
        local spawnpoint = mini.f().new()
        local bore = mini.g().new()
        local pipeextender = mini.h().new()
        local silentaim = mini.j().new()
        local damageindicator = mini.k().new()
        local visuals = mini.l().new()
        local artillery = mini.m().new()
        local autodcap = mini.n().new()
        local autoshield = mini.o()
        local heightlimit = mini.p()
        for name, value in
            {
                main = main,
                bore = bore,
                artillery = artillery,
                spawnpoint = spawnpoint,
                autodcap = autodcap,
                instantRespawnCall = instantRespawnCall,
                instantTPCall = instantTPCall,
                heightlimit = heightlimit,
                selectedSpawn = "",
                lockedOn = nil,
            }
        do
            container[name] = value
        end

        heightlimit:start()
        main:start()
        bore:start()
        pipeextender:start()
        spawnpoint:start()
        silentaim:start()
        damageindicator:start()

        RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
            artillery:update()
            spawnpoint:update()
            visuals:update()
            silentaim:update()
            selectedSpawnLabel:SetText(
(rawget(container, "selectedSpawn")
and{(string.format("Selecting <font color='#42d1f5'><b>S%s</b></font>", tostring(container.selectedSpawn)))}or{"<font color='#f54242'><b>NO SPAWN</b></font>"})[1]            

)
        end))
        workspace:WaitForChild("Structures").ChildAdded:Connect(function(child)
            autodcap:start(child)
            autoshield(child)
        end)
        workspace:WaitForChild("Structures").ChildRemoved:Connect(function(child)
        end)
    end
end

obsidian.autoload()
