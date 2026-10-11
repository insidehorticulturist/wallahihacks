

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
    UtilityMods:AddCheckbox("ArtyGravity", {Text = "Arty Gravity (PRE ECO ONLY)"})
    UtilityMods:AddSlider(
        "GravitySlider",
        { Text = "Set Arty Gravity", Default = 70, Min = 1, Max = 100, Tooltip = "Default: 70" }
    )

    local PortafabMods = LocalTab:AddLeftGroupbox("Portafab")
    PortafabMods:AddCheckbox(
        "PORTAFAB/InfiniteRange",
        { Text = "Infinite Context Range", FormatDisplayValue = function() end }
    )

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

    local BoreAimSection = AimbotTab:AddRightGroupbox("Bore Aimbot")
    BoreAimSection:AddCheckbox("BoreAimbot", {Text = "Bore Aimbot", Tooltip = "When you aim a bore at another bore, it will automatically reaim towards the tilt assembly of the bore (top)"})
    BoreAimSection:AddCheckbox("AimAtCenterOfOtherParts", {Text = "Aim at center", Tooltip = "Whether or not aiming a bore will reaim towards the center of a part."})
    local AutoStuff = AutoTab:AddLeftGroupbox("Auto")
    AutoStuff:AddCheckbox("AutoDCap", {Text = "Auto DCap"})
    AutoStuff:AddSlider("AutoDCapDelay", { Text = "AutoDCapDelay", Default = 0.1, Min = 0, Max = 1, Rounding = 2 })
    AutoStuff:AddDropdown("AutoDCapDropdown", {
        Text = "Select Structures",
        Multi = true,
        Values = {
            "Arc Turret",
            "Turret",
            "Fabricator",
            "Automechanic",
            "Boost Pad",
            "Observer",
            "Spatial Anchor",
            "Spawn Point",
            "Shield Generator",
            "Point Defense",
        }
    })
    AutoStuff:AddCheckbox("AutoShield", {Text = "AutoShield", Tooltip = "Automatically turns on shields and anchors when placed"})
    AutoStuff:AddCheckbox("AutoBorePipe", {Text = "Auto four-way bores"})

    local ArtillerySection = VisualTab:AddLeftGroupbox("Artillery")
    ArtillerySection:AddCheckbox("artyVisual", { Text = "Arty Trajectory Visual" })
    ArtillerySection:AddLabel("Artillery Color"):AddColorPicker("artyVisualColor", {
        Default = Color3.fromRGB(60, 255, 0),
        Title = "Artillery Color",
        Transparency = 0,
    })
    ArtillerySection:AddSlider(
        "artyVisualSize",
        { Text = "Set Arty Size", Default = 0.1, Min = 0.05, Max = 5, Rounding = 2 }
    )

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
    UtilityVisualSection:AddDivider()
    UtilityVisualSection:AddCheckbox("HeightLimitESP", { Text = "HeightLimit Esp" })
        :AddColorPicker(
            "HeighLimitColor",
            { Title = "Height ESP Color", Default = Color3.fromRGB(255, 0, 0) }
        )
    UtilityVisualSection:AddSlider("HeightlimitSize", { Text = "Height Limit ESP Size", Default = 2, Min = 1, Max = 30 })
    UtilityVisualSection:AddDivider()

    UtilityVisualSection:AddCheckbox("BeaconSpotESP", { Text = "Beacon Spot ESP" })
        :AddColorPicker(
            "BeaconSpotColor",
            { Title = "Beacon ESP Color", Default = Color3.fromRGB(255, 102, 0) }
        )
    UtilityVisualSection:AddDivider()
    local beamColorToggle = UtilityVisualSection:AddCheckbox("ChangeBeamColors", {Text = "Change Distributor Beam Color"})
    beamColorToggle:AddColorPicker(
        "FirstBeamColor",
        { Title = "BeamColorOne", Default = Color3.fromRGB(0, 255, 255) }
    )
    beamColorToggle:AddColorPicker(
        "SecondBeamColor",
        { Title = "BeamColortwo", Default = Color3.fromRGB(0, 255, 255) }
    )

    local BoreVisualsSection = VisualTab:AddRightGroupbox("Bore Visuals")
    BoreVisualsSection:AddCheckbox("NeonBores",{Text = "Neon Bores"})
    BoreVisualsSection:AddCheckbox("BoreBeamColorChange", {Text = "Change Bore Beam Color"})
        :AddColorPicker("BoreBeamColor", {Title = "BoreBeamColorDesu", Default = Color3.fromRGB(0, 255, 255)})
    local previewBeamToggle = BoreVisualsSection:AddCheckbox("PreviewBeamColorChange",{Text = "Preview Beam Color Change"})
    previewBeamToggle:AddColorPicker(
        "PreviewBeamColorOne",
        { Title = "Previewbeamcolorone", Default = Color3.fromRGB(0, 255, 255)}
    )
    previewBeamToggle:AddColorPicker(
        "PreviewBeamColorTwo",
        { Title = "Previewbeamcolortwo", Default = Color3.fromRGB(0, 255, 255)}
    )
    local boreFlareToggle = BoreVisualsSection:AddCheckbox("BoreFlareColors",{Text = "Bore Flare Colors"})
    boreFlareToggle:AddColorPicker(
        "BoreFlareColorOne",
        { Title = "Boreflarecolorone", Default = Color3.fromRGB(0, 255, 255)}
    )
    boreFlareToggle:AddColorPicker(
        "BoreFlareColorTwo",
        { Title = "Boreflarecolortwo", Default = Color3.fromRGB(0, 255, 255)}
    )

    do
        local artygrav = require("@core/artygrav").new()
        local container = require("@Util/container")
        local beamcolor = require("@core/beamcolors").new()
        local main = require("@core/main").new()
        local spawnpoint = require("@core/spawnpoints").new()
        local bore = require("@core/autoaimbore").new()
        local pipeextender = require("@core/pipeextender").new()
        local silentaim = require("@core/silentaim").new()
        local damageindicator = require("@core/damageindicator").new()
        local visuals = require("@core/visuals").new()
        local artillery = require("@core/artillery").new()
        local autodcap = require("@core/autodcap").new()
        local autoshield = require("@core/autoshield")
        local heightlimit = require("@core/heighlimit").new()
        local beaconspotesp = require("@core/beaconspotesp").new()
        local boreaimbot = require("@core/boreaimbot").new()
        local borecustomize = require("@core/borecustom").new()
        local autoborepipe = require("@core/autoborepipe").new()
        local nofall = require("@core/nofall")

        for name, value in
            {
                artygrav = artygrav,
                autoborepipe = autoborepipe,
                borecustomize = borecustomize,
                boreaimbot = boreaimbot,
                beamcolor = beamcolor,
                beaconspotesp = beaconspotesp,
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
        artygrav:start()
        autoborepipe:start()
        borecustomize:start()
        boreaimbot:start()
        beamcolor:start()
        beaconspotesp:start()
        heightlimit:start()
        main:start()
        bore:start()
        pipeextender:start()
        spawnpoint:start()
        silentaim:start()
        damageindicator:start()

        -- SetText rebuilds the rich text label, so only call it when the spawn changes
        local shownSpawn = {}

        RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
            artillery:update()
            spawnpoint:update()
            visuals:update()
            silentaim:update()
            heightlimit:update()

            if container.selectedSpawn ~= shownSpawn then
                shownSpawn = container.selectedSpawn
                selectedSpawnLabel:SetText(
                    if shownSpawn
                        then `Selecting <font color='#42d1f5'><b>S{shownSpawn}</b></font>`
                        else `<font color='#f54242'><b>NO SPAWN</b></font>`
                )
            end
        end))
        workspace:WaitForChild("Structures").ChildAdded:Connect(function(child)
            -- both yield, so run them side by side instead of making autoshield wait on autodcap
            task.spawn(autodcap.start, autodcap, child)
            task.spawn(autoshield, child)
        end)

        Toggles.FallDamage:OnChanged(function()
            nofall.SetFallDamage(not Toggles.FallDamage.Value)
        end)

        -- the fall damage script comes back with every character, so turn it off again
        game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
            if not Toggles.FallDamage.Value then
                return
            end

            character:WaitForChild("FallDamageScript", 10)
            for _ = 1, 10 do
                task.wait(0.5)
                if not Toggles.FallDamage.Value or nofall.SetFallDamage(false) then
                    return
                end
            end
        end)
    end
end

obsidian.autoload()
