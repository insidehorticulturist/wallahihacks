loadstring([[
    function LPH_NO_VIRTUALIZE(f) return f end;
	function LPH_JIT(f) return f end;
	function LPH_JIT_MAX(f) return f end;
	function LPH_NO_UPVALUES(f) return f end;
]])()

local RunService = game:GetService("RunService")

local signal = require("@Util/Signal")
local obsidian = require("@Util/obsidian")
local nccam = require("./core/nccam")

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
            return `S{value}`
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
        local container = require("@Util/container")

        local main = require("./core/main").new()
        local spawnpoint = require("./core/spawnpoints").new()
        local bore = require("./core/autoaimbore").new()
        local pipeextender = require("./core/pipeextender").new()
        local silentaim = require("./core/silentaim").new()
        local damageindicator = require("./core/damageindicator").new()
        local visuals = require("./core/visuals").new()
        local artillery = require("./core/artillery").new()
        local autodcap = require("./core/autodcap").new()
        local autoshield = require("./core/autoshield")
        local heightlimit = require("./core/heighlimit")
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
                if rawget(container, "selectedSpawn")
                    then `Selecting <font color='#42d1f5'><b>S{container.selectedSpawn}</b></font>`
                    else `<font color='#f54242'><b>NO SPAWN</b></font>`
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
